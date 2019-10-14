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

  continuousIntegration: {
    local buildUrl = '%s/{{repo.owner}}/{{repo.name}}/{{build.number}}' % droneHost,
    local commitUrl = '%s/link/{{repo.owner}}/{{repo.name}}/commit/{{build.commit}}' % droneHost,

    buildStarted: @':arrow_forward: Started <%s|{{repo.name}} build #{{build.number}}> on _{{build.branch}}_' % buildUrl,
    buildCompleted:
      '{{#success build.status}}\n'+
      '  :+1: *<%s|BUILD SUCCESS: #{{build.number}}>*\n' % buildUrl +
      '{{else}}\n' +
      '  :octagonal_sign: *<%s|BUILD FAILURE: #{{build.number}}>*\n' % buildUrl +
      '{{/success}}\n' +
      '\n' +
      'Project: *{{repo.name}}*\n' +
      'Triggered by: commit to _{{build.branch}}_ (*<%s|{{truncate build.commit 8}}>*)\n' % commitUrl +
      '\n' +
      '```{{build.message}}```'
  },
  promotion: {
    local linkedSha = '*<%s/link/{{repo.owner}}/{{repo.name}}/commit/{{build.commit}}|{{repo.name}}@{{truncate build.commit 8}}>*' % droneHost,
    local buildNumberString = '(<%s/{{repo.owner}}/{{repo.name}}/{{build.number}}|Build #{{build.number}}>)' % droneHost,

    buildStarted: ':arrow_up: Promoting %s to _{{build.deployTo}}_. %s' % [linkedSha, buildNumberString],
    buildCompleted:
      '{{#success build.status}}\n' +
      '  :checkered_flag: Successfully promoted %s to _{{build.deployTo}}_. %s\n' % [linkedSha, buildNumberString] +
      '{{else}}\n' +
      '  :octagonal_sign: Failed to promote %s to _{{build.deployTo}}_. %s\n' % [linkedSha, buildNumberString] +
      '{{/success}}\n' +
      '\n' +
      'Build message:\n' +
      '\n' +
      '```{{build.message}}```\n'
  },
};

local configurePipelines(steps, when, env, utils) = pipelineBuilder(steps, when, env, utils, templates);
