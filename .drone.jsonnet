local createPipelines(steps) = [
  {
    name: 'continuous-integration',

    npmPublish: {
      tokenSecret: 'NPM_PUBLISH_TOKEN',
    },

    steps: [
      steps.custom('temp', {
       image: 'node',
//       commands: ['echo ">>> Hello, $${RELEASE_PREID}!"'],
       commands: ['set'],
     }),


      steps.yarn('install'),

      steps.yarn('bootstrap'),
      steps.yarn('build'),
      steps.yarn('test'),

      steps.yarn('publish-prerelease', ['release:pre --yes'], {
        when: {
          branch: ['develop']
        }
      }),

      steps.yarn('publish-release', ['release:graduate --yes'], {
        when: {
          branch: ['master']
        }
      }),
    ]
  },
];

// !!! BEGIN AUTO-GENERATED CONFIGURATION !!!
// !!! The following content is not meant to be edited by hand
// !!! Changes below this line may be overwritten by generators in thrashplay-app-creators

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
  },

  createStep(pipelineConfig):: function (step) {
      name: step.name,
      environment: pipelineConfig.environment,
    } + if (std.objectHas(step, 'builder'))
        then (if (std.objectHas(step, 'config')) then step.config else {}) + step.builder(pipelineConfig)
        else {},

  getInitSteps(pipelineConfig)::
    [
      {
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
      },
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

  createPipeline(configuration = {}): {
    local config = __pipelineFactory.withDefaults(configuration),

    kind: 'pipeline',
    name: config.name,
    steps: __pipelineFactory.getInitSteps(config) + std.map(__pipelineFactory.createStep(config), config.steps),
  },

  configBuilders:: {
    custom: {
      getStepConfig(name, config = {}): {
        name: name,
        config: config,
        builder: __pipelineFactory.configBuilders.custom.buildStep,
      },

      // use provided configuration, without augmenting it
      buildStep(pipelineConfig): {},
    },

    yarn: {
      getStepConfig(name, scripts = [name], config = {}): {
        name: name,
        config: config,
        builder: __pipelineFactory.configBuilders.yarn.buildStep({ scripts: scripts }),
      },

      buildStep(stepConfig): function (pipelineConfig) {
        image: pipelineConfig.nodeImage,
        commands:
          [': *** yarn -- running commands: [' + std.join(', ', stepConfig.scripts) + ']'] +
          std.map(__pipelineFactory.configBuilders.yarn.createCommand, stepConfig.scripts),
      },

      createCommand(script):: std.join(' ', ['yarn', script]),
    },
  },
};

std.map(__pipelineFactory.createPipeline, createPipelines({
  custom: __pipelineFactory.configBuilders.custom.getStepConfig,
  yarn: __pipelineFactory.configBuilders.yarn.getStepConfig,
}))