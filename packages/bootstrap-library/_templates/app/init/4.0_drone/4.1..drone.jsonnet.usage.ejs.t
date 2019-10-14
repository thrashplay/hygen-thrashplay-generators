---
to: <% if (ciType === 'drone') { %><%= projectDir %>/.drone.jsonnet<% } else { null } %>
---
local slackConfig() = {
  webhookSecret: 'SLACK_NOTIFICATION_WEBHOOK',
  channel: 'devops',
};

local createBuildSteps(steps) = [
  steps.yarn('install', ['install --frozen-lockfile --non-interactive']),
  steps.yarn('bootstrap'),

  steps.yarn('precheck', ['commitlint --verbose --from HEAD~1 --to HEAD', 'lint']),
  steps.yarn('build'),

  steps.yarn('test'),
];

local pipelineBuilder = function (steps, when, env, utils, templates) [
  {
    local isPublishable = when(branch = 'master'),

    name: 'continuous-integration',
    slack: slackConfig(),

    steps:
      utils.join([
        steps.slack(templates.continuousIntegration.buildStarted, 'notify-start'),
        createBuildSteps(steps),
        steps.custom('amend-commit-message', 'drone/git', 'sh .ci/amend-commit.sh') + isPublishable,

        // publish prereleases from every master build
        steps.release(
        {
          npmTokenSecret: 'NPM_PUBLISH_TOKEN',
          version: ['version:prerelease --preid next --no-push --amend --yes'],
//          publish: ['publish:tagged --dist-tag next --yes'],
        }) + isPublishable,

        steps.custom('push-tags', 'drone/git', 'sh .ci/push-tags.sh') + isPublishable,
        steps.slack(templates.continuousIntegration.buildCompleted, 'notify-complete') + when(status = ['success', 'failure']),
      ]),

    trigger: {
      event: {
        include: ['push'],
      }
    },
  },
  {
    name: 'promote-build',
    slack: slackConfig(),

    steps:
      utils.join([
        steps.slack(templates.promotion.buildStarted, 'notify-start'),
        createBuildSteps(steps),

        // promote build from any branch, because it's manual
        steps.release({
          npmTokenSecret: 'NPM_PUBLISH_TOKEN',
          version: ['version:graduate --yes'],
          publish: [
            'publish:tagged --dist-tag ${DRONE_DEPLOY_TO} --yes',
          ]
        }),

        steps.slack(templates.promotion.buildCompleted, 'notify-complete')
          + when(status = ['success', 'failure']),
      ]),

    trigger: {
      event: {
        include: ['promote'],
      }
    }
  },
];

local templates = {
  local droneHost = 'https://PLACEHOLDER_URL',
  local buildUrl = '%s/{{repo.owner}}/{{repo.name}}/{{build.number}}' % droneHost,

  continuousIntegration: {
    local commitUrl = '%s/link/{{repo.owner}}/{{repo.name}}/commit/{{build.commit}}' % droneHost,

    buildStarted:
      ':arrow_forward: *<%s|STARTING {{repo.name}} #{{build.number}}>*\n' % buildUrl +
      'Building: <%s|{{truncate build.commit 8}}> on branch _{{build.branch}}_' % commitUrl,
    buildCompleted:
      '{{#success build.status}}\n' +
      '  :+1: *<%s|BUILD SUCCESS: #{{build.number}}>*\n' % buildUrl +
      '  Project: _{{repo.name}}_\n' +
      '  Built: <%s|{{truncate build.commit 8}}> on branch _{{build.branch}}_' % commitUrl +
      '{{else}}\n' +
      '  :octagonal_sign: *<%s|BUILD FAILED: #{{build.number}}>*\n' % buildUrl +
      '  Project: _{{repo.name}}_\n' +
      "  Failed: Building <%s|{{truncate build.commit 8}}> on branch _{{build.branch}}_" % commitUrl +
      '{{/success}}\n' +
      '\n' +
      '```{{build.message}}```',
  },
  publishing(releaseChannel): {
    buildStarted:
      ':newspaper: *<%s|STARTING {{repo.name}} #{{build.number}}>*\n' % buildUrl +
      'Publishing: {{build.tag}} to _%s_\n' % releaseChannel,
    buildCompleted:
      '{{#success build.status}}\n' +
      '  :checkered_flag: *<%s|BUILD SUCCESS: #{{build.number}}>*\n' % buildUrl +
      '  Project: _{{repo.name}}_\n' +
      "  Published: {{build.tag}} to channel _%s_\n" % releaseChannel +
      '{{else}}\n' +
      '  :octagonal_sign: *<%s|BUILD FAILED: #{{build.number}}>*\n' % buildUrl +
      '  Project: _{{repo.name}}_\n' +
      "  Failed: Publishing {{build.tag}} to channel _%s_\n" % releaseChannel +
      '{{/success}}\n'
  },
  promotion: {
    buildStarted:
      ':arrow_up: *<%s|STARTING {{repo.name}} #{{build.number}}>*\n' % buildUrl +
      'Promoting: {{build.tag}} to _{{build.deployTo}}_\n',
    buildCompleted:
      '{{#success build.status}}\n' +
      '  :checkered_flag: *<%s|BUILD SUCCESS: #{{build.number}}>*\n' % buildUrl +
      '  Project: _{{repo.name}}_\n' +
      "  Promoted: {{build.tag}} to channel _{{build.deployTo}}_\n" +
      '{{else}}\n' +
      '  :octagonal_sign: *<%s|BUILD FAILED: #{{build.number}}>*\n' % buildUrl +
      '  Project: _{{repo.name}}_\n' +
      "  Failed: Promoting {{build.tag}} to channel _{{build.deployTo}}_\n" +
      '{{/success}}\n'
  },
};

local configurePipelines(steps, when, env, utils) = pipelineBuilder(steps, when, env, utils, templates);
