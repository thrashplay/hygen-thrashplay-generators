local createBuildSteps(steps) = [
  steps.yarn('install', ['install --frozen-lockfile --non-interactive']),
  steps.yarn('bootstrap'),

  steps.yarn('precheck', ['commitlint:last', 'lint']),
  steps.yarn('build'),

  steps.yarn('test'),
];

local createPipelines(steps) = [
  {
    name: 'continuous-integration',

    steps: createBuildSteps(steps) + [
      steps.publish({
        tokenSecret: 'NPM_PUBLISH_TOKEN',
        configurations: [
          {
            branches: ['master'],
            prerelease: 'next',
          }
        ]
      }),
    ],

    notifications: {
      slack: {
        webhookSecret: 'SLACK_NOTIFICATION_WEBHOOK',
        channel: 'automation',

        startMessage: |||
          :arrow_forward: Started <https://drone.thrashplay.com/thrashplay/{{repo.name}}/{{build.number}}|{{repo.name}} build #{{build.number}}> on _{{build.branch}}_
        |||,

        completeMessage: |||
          {{#success build.status}}
            :+1: *<https://drone.thrashplay.com/thrashplay/{{repo.name}}/{{build.number}}|BUILD SUCCESS: #{{build.number}}>*
          {{else}}
            :octagonal_sign: *<https://drone.thrashplay.com/thrashplay/{{repo.name}}/{{build.number}}|BUILD FAILURE: #{{build.number}}>*
          {{/success}}

          Project: *{{repo.name}}*
          Triggered by: commit to _{{build.branch}}_ (*<https://drone.thrashplay.com/link/thrashplay/{{repo.name}}/commit/{{build.commit}}|{{truncate build.commit 8}}>*)

          ```{{build.message}}```
        |||
      },
    },

    trigger: {
      event: {
        include: ['push'],
      }
    }
  },
  {
      name: 'promote-build',

      steps: createBuildSteps(steps) + [
        steps.publish({
          tokenSecret: 'NPM_PUBLISH_TOKEN',
          promotion: {
            allowedBranches: ['master'],
            extraDistTags: ['latest'],
            scriptName: 'release:graduate',
          },
        }),
      ],

      notifications: {
        slack: {
          local linkedSha = '*<https://drone.thrashplay.com/link/thrashplay/{{repo.name}}/commit/{{build.commit}}|{{repo.name}}@{{truncate build.commit 8}}>*',
          local buildNumberString = '(<https://drone.thrashplay.com/thrashplay/{{repo.name}}/{{build.number}}|Build #{{build.number}}>)',

          webhookSecret: 'SLACK_NOTIFICATION_WEBHOOK',
          channel: 'automation',

          startMessage: '::arrow_up:: Promoting ' + linkedSha + ' to _{{build.deployTo}}_. ' + buildNumberString,

          completeMessage: '{{#success build.status}}:checkered_flag: Successfuly promoted ' + linkedSha + ' to _{{build.deployTo}}_. ' + buildNumberString +
            '{{else}}' +
            '  :octagonal_sign: Failed to deploy ' + linkedSha + ' to _{{build.deployTo}}_. ' + buildNumberString +
            '{{/success}}'
        },
      },

      trigger: {
        event: {
          include: ['promote'],
        }
      }
    },
];

// !!! BEGIN AUTO-GENERATED CONFIGURATION !!!
// !!! The following content is not meant to be edited by hand
// !!! Changes below this line may be overwritten by generators in thrashplay-app-creators

local __initGitHubStep(pipelineConfig) = {
   local defaultEmail = "`git log -1 --pretty=format:'%ae'`",
   local defaultName = "`git log -1 --pretty=format:'%an'`",
   local authorEmail =
     if std.objectHas(pipelineConfig, 'git') then
       if std.objectHas(pipelineConfig.git, 'authorEmail') then pipelineConfig.git.authorEmail else defaultEmail
     else
       defaultEmail,

  local authorName =
     if std.objectHas(pipelineConfig, 'git') then
       if std.objectHas(pipelineConfig.git, 'authorName') then pipelineConfig.git.authorName else defaultName
     else
       defaultName,

   name: 'init-git',
   image: 'alpine/git',
   commands: [
     ': *** Initializing git user information...',
     'git config --local user.email "' + authorEmail + '"',
     'git config --local user.name "' + authorName + '"',
   ],
 };

local __custom(name, config = {}) = {
  builder: function (pipelineConfig) [
    config + {
      name: name,
    }
  ],
};

local __createCommand(script) = std.join(' ', ['yarn', script]);
local __yarn(name, scripts = [name], config = {}) = {
  builder: function (pipelineConfig) [
    config + {
      name: name,
      image: pipelineConfig.nodeImage,
      commands: [': *** yarn -- running commands: [' + std.join(', ', scripts) + ']'] + std.map(__createCommand, scripts),
    }
  ],
};

local __createPublishStep(image, baseStepName, publishConfig, environment = {}) = function(publish) {
  local prereleaseScriptName =
    if std.objectHas(publishConfig, 'prereleaseScriptName')
    then publishConfig.prereleaseScriptName
    else 'release:pre',

  local releaseScriptName =
    if std.objectHas(publishConfig, 'releaseScriptName')
    then publishConfig.releaseScriptName
    else 'release:graduate',

  local releaseName = if std.objectHas(publish, 'prerelease') then publish.prerelease else 'production',
  local scriptName = if std.objectHas(publish, 'prerelease')
    then prereleaseScriptName
    else releaseScriptName,
  local isCanary = std.objectHas(publish, 'canary') && publish.canary,

  name: std.join('-', [baseStepName, releaseName]),
  image: image,
  environment: environment + if std.objectHas(publish, 'prerelease') then { PRERELEASE_ID: publish.prerelease } else {},
  commands: [
    ': *** publishing: ' + releaseName,
    std.join(' ', ['yarn', scriptName, if isCanary then '--canary']),
  ],
  when: {
    branch: publish.branches,
  }
};
local __publish(publishConfig = {}) = {
  local baseStepName =
    if std.objectHas(publishConfig, 'baseStepName')
    then publishConfig.baseStepName
    else 'publish',

  local tokenSecret =
    if std.objectHas(publishConfig, 'tokenSecret')
    then publishConfig.tokenSecret
    else 'NPM_PUBLISH_TOKEN',

  builder: function (pipelineConfig)
    (if std.objectHas(publishConfig, 'configurations') then [
      {
        name: std.join('-', [baseStepName, 'npm-auth']),
        image: 'robertstettner/drone-npm-auth',
        settings: {
          token: {
            from_secret: tokenSecret,
          }
        },
      },
    ] else []) +
    (if std.objectHas(publishConfig, 'configurations')
      then std.map(__createPublishStep(
        pipelineConfig.nodeImage,
        baseStepName,
        publishConfig), publishConfig.configurations)
      else []) +
    (if std.objectHas(publishConfig, 'promotion')
      then [{
        name: std.join('-', ['promote', '${DRONE_DEPLOY_TO}']),
          image: pipelineConfig.nodeImage,
          environment: pipelineConfig.environment + { PROMOTED_TO: '${DRONE_DEPLOY_TO}' },
          commands: [
            'echo *** promoting to $${PROMOTED_TO} release',
            std.join(' ', ['echo yarn', 'release:graduate']),
          ],
      }] else [])
};

local __pipelineFactory = {
  /**
   * Apply default configurations to a pipeline config.
   */
  withDefaults(configuration = {}):: configuration + {
    local defaultEnvironment = {},
    environment: defaultEnvironment + if std.objectHas(configuration, 'environment') then configuration.environment else {},
    name: if std.objectHas(configuration, 'name') then configuration.name else 'default',
    nodeImage: if std.objectHas(configuration, 'nodeImage') then configuration.nodeImage else 'node:lts',
    steps: if std.objectHas(configuration, 'steps') then configuration.steps else [],
    trigger: if std.objectHas(configuration, 'trigger') then configuration.trigger else {},
  },

  withEnvironment(pipelineConfig):: function (step) { environment: pipelineConfig.environment } + step,

  getStartNotificationSteps(pipelineConfig)::
    if (std.objectHas(pipelineConfig, 'notifications') && std.objectHas(pipelineConfig.notifications, 'slack') && std.objectHas(pipelineConfig.notifications.slack, 'startMessage'))
      then [
        {
          image: 'plugins/slack',
          name: 'slack-notify-start',
          settings: {
            channel: pipelineConfig.notifications.slack.channel,
            template: pipelineConfig.notifications.slack.startMessage,
            webhook: {
              from_secret: pipelineConfig.notifications.slack.webhookSecret,
            },
          }
        }
      ]
      else [],

  getCompleteNotificationSteps(pipelineConfig)::
    if (std.objectHas(pipelineConfig, 'notifications') && std.objectHas(pipelineConfig.notifications, 'slack') && std.objectHas(pipelineConfig.notifications.slack, 'completeMessage'))
      then [
        {
          image: 'plugins/slack',
          name: 'slack-notify-complete',
          settings: {
            webhook: {
              from_secret: pipelineConfig.notifications.slack.webhookSecret,
            },
            channel: pipelineConfig.notifications.slack.channel,
            template: pipelineConfig.notifications.slack.completeMessage,
          },
          when: {
            status: [ 'success', 'failure' ]
          }
        }
      ]
      else [],

  getInitSteps(pipelineConfig)::
    __pipelineFactory.getStartNotificationSteps(pipelineConfig) +
    [
      __initGitHubStep(pipelineConfig)
    ],

  createSteps(pipelineConfig):: function (step)
    std.map(
      __pipelineFactory.withEnvironment(pipelineConfig),
      if (std.objectHas(step, 'builder')) then step.builder(pipelineConfig) else []),

  createPipeline(configuration = {}): {
    local config = __pipelineFactory.withDefaults(configuration),

    kind: 'pipeline',
    name: config.name,
    steps:
      __pipelineFactory.getInitSteps(config) +
      std.flattenArrays(std.map(__pipelineFactory.createSteps(config), config.steps)) +
      __pipelineFactory.getCompleteNotificationSteps(config),
    trigger: config.trigger,
  },
};

std.map(__pipelineFactory.createPipeline, createPipelines({
  custom: __custom,
  publish: __publish,
  yarn: __yarn,
}))
