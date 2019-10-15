---
to: <% if (ciType === 'drone') { %><%= projectDir %>/.drone.jsonnet<% } else { null } %>
---
local droneHost = 'PLACEHOLDER_URL;

// the release channel to promote builds too
local releaseChannel = 'alpha';

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
    name: 'continuous-integration',
    slack: slackConfig(),

    steps:
      utils.join([
        steps.slack(templates.continuousIntegration.buildStarted, 'notify-start'),
        createBuildSteps(steps),

        // publish prereleases from every master build
        steps.release(
        {
          version: {
            amend: true,
            lernaOptions: ['--conventional-prerelease', '--preid', 'next'],
          },
        }) + when(branch = 'master'),

        steps.slack(templates.continuousIntegration.buildCompleted, 'notify-complete') + when(status = ['success', 'failure']),
      ]),

    trigger: {
      event: {
        include: ['push'],
      }
    },
  },
  {
    name: 'publish-tag',
    slack: slackConfig(),

    steps:
      utils.join([
        steps.slack(templates.publishing('next').buildStarted, 'notify-start'),
        steps.yarn('install', ['install --frozen-lockfile --non-interactive']),
        steps.yarn('bootstrap'),
        steps.yarn('build'),

        // publish prereleases from every master build
        steps.release(
        {
          publish: {
            channels: 'next',
            lernaOptions: 'from-package',
            npmTokenSecret: 'NPM_PUBLISH_TOKEN',
          },
        }),

        steps.slack(templates.publishing('next').buildCompleted, 'notify-complete') + when(status = ['success', 'failure']),
      ]),

    trigger: {
      event: {
        include: ['tag'],
      }
    },
  },
  {
    name: 'promote-build',
    slack: slackConfig(),

    // use Drone credentials for publish chores
    git: {
      authorEmail: 'drone@thrashplay.com',
      authorName: 'Drone',
    },

    steps:
      utils.join([
        steps.slack(templates.promotion(releaseChannel).buildStarted, 'notify-start'),
        steps.yarn('install', ['install --frozen-lockfile --non-interactive']),
        steps.yarn('bootstrap'),
        steps.yarn('build'),


        // promote build from any branch, because it's manual
        steps.release({
          npmTokenSecret: 'NPM_PUBLISH_TOKEN',
          version: {
            amend: false,
            lernaOptions: '--conventional-graduate',
          },
          publish: {
            channels: [releaseChannel],
            npmTokenSecret: 'NPM_PUBLISH_TOKEN',
            lernaOptions: 'from-git',
          }
        }),

        steps.slack(templates.promotion(releaseChannel).buildCompleted, 'notify-complete')
          + when(status = ['success', 'failure']),
      ]),

    trigger: {
      event: {
        include: ['custom'],
      }
    }
  },
];

local templates = {
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
      ':arrow_forward: *<%s|STARTING {{repo.name}} #{{build.number}}>*\n' % buildUrl +
      'Publishing: {{build.tag}} to channel _%s_\n' % releaseChannel,
    buildCompleted:
      '{{#success build.status}}\n' +
      '  :+1: *<%s|BUILD SUCCESS: #{{build.number}}>*\n' % buildUrl +
      '  Project: _{{repo.name}}_\n' +
      "  Published: {{build.tag}} to channel _%s_\n" % releaseChannel +
      '{{else}}\n' +
      '  :octagonal_sign: *<%s|BUILD FAILED: #{{build.number}}>*\n' % buildUrl +
      '  Project: _{{repo.name}}_\n' +
      "  Failed: Publishing {{build.tag}} to channel _%s_\n" % releaseChannel +
      '{{/success}}\n'
  },
  promotion(releaseChannel): {
    buildStarted:
      ':arrow_up: *<%s|STARTING {{repo.name}} #{{build.number}}>*\n' % buildUrl +
      'Promoting: branch _{{build.branch}}_ to channel _%s_\n' % releaseChannel,
    buildCompleted:
      '{{#success build.status}}\n' +
      '  :checkered_flag: *<%s|BUILD SUCCESS: #{{build.number}}>*\n' % buildUrl +
      '  Project: _{{repo.name}}_\n' +
      "  Promoted: branch _{{build.branch}}_ to channel _%s_\n" % releaseChannel +
      '{{else}}\n' +
      '  :octagonal_sign: *<%s|BUILD FAILED: #{{build.number}}>*\n' % buildUrl +
      '  Project: _{{repo.name}}_\n' +
      "  Failed: Promoting branch _{{build.branch}}_ to channel _%s_\n" % releaseChannel +
      '{{/success}}\n'
  },
};

local configurePipelines(steps, when, env, utils) = pipelineBuilder(steps, when, env, utils, templates);
