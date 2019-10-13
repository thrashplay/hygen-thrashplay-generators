local createPipelines(steps) = [
  {
    steps: [
      steps.yarn('install', ['install --frozen-lockfile --non-interactive']),

      steps.yarn('bootstrap'),
      steps.yarn('build'),
      steps.yarn('test'),

      steps.publish({
        tokenSecret: 'NPM_PUBLISH_TOKEN',
        prereleases: {
          alpha: ['master'],
          development: ['develop'],
          unstable: {
            exclude: ['master', 'develop']
          }
        }
      }),

      steps.custom('slack-notification', {
        image: 'plugins/slack',
        settings: {
          webhook: {
            from_secret: 'SLACK_NOTIFICATION_WEBHOOK',
          },
          channel: 'deployments',
          template: |||
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
        when: {
          status: [ 'success', 'failure' ]
        }
      })
    ],

    trigger: {
      event: {
        include: ['push'],
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

local __createReleaseStep(image, baseStepName, stepName, scriptName, branch, environment = {}) = {
  name: std.join('-', [baseStepName, stepName]),
  image: image,
  environment: environment,
  commands: [
    ': *** publishing release',
    std.join(' ', ['yarn', scriptName]),
  ],
  when: {
    branch: [branch]
  }
};
local __createPrereleaseStep(prereleaseConfig, image, baseStepName, scriptName, environment = {}) = function(prereleaseName) {
  name: std.join('-', [baseStepName, 'prerelease', prereleaseName]),
  image: image,
  environment: environment + { PRERELEASE_ID: prereleaseName },
  commands: [
    ': *** publishing pre-release: ' + prereleaseName,
    std.join(' ', ['yarn', scriptName]),
  ],
  when: {
    branch: prereleaseConfig[prereleaseName]
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

  local prereleaseScriptName =
    if std.objectHas(publishConfig, 'prereleaseScriptName')
    then publishConfig.prereleaseScriptName
    else 'release:pre',

  local releaseScriptName =
    if std.objectHas(publishConfig, 'releaseScriptName')
    then publishConfig.releaseScriptName
    else 'release:graduate',

  local releaseBranch =
    if std.objectHas(publishConfig, 'branch')
    then publishConfig.branch
    else 'master',

  builder: function (pipelineConfig)
    [
      {
        name: std.join('-', [baseStepName, 'npm-auth']),
        image: 'robertstettner/drone-npm-auth',
        settings: {
          token: {
            from_secret: tokenSecret,
          }
        },
      },
    ] +
    if std.objectHas(publishConfig, 'branch')
      then [__createReleaseStep(pipelineConfig.nodeImage, baseStepName, 'release', releaseScriptName, releaseBranch)]
      else [] +
    if std.objectHas(publishConfig, 'prereleases')
      then std.map(__createPrereleaseStep(
        publishConfig.prereleases,
        pipelineConfig.nodeImage,
        baseStepName,
        prereleaseScriptName), std.objectFields(publishConfig.prereleases))
      else []
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

  getInitSteps(pipelineConfig)::
    [
      __initGitHubStep(pipelineConfig)
    ] + if std.objectHas(pipelineConfig, 'npmPublish') then
    [
      {
        name: 'init-npm-auth',
        image: 'robertstettner/drone-npm-auth',
        settings: {
          token: {
            from_secret: pipelineConfig.npmPublish.tokenSecret,
          }
        },
      }
    ] else [],

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
      std.flattenArrays(std.map(__pipelineFactory.createSteps(config), config.steps)),
    trigger: config.trigger,
  },
};

std.map(__pipelineFactory.createPipeline, createPipelines({
  custom: __custom,
  publish: __publish,
  yarn: __yarn,
}))