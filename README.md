[![Build Status](https://drone.thrashplay.com/api/badges/thrashplay/thrashplay-app-creators/status.svg)](https://drone.thrashplay.com/thrashplay/thrashplay-app-creators) 

# thrashplay-app-creators
Generator project for creating new applications and libraries using Thrashplay's conventions 
for new projects. The tools in this package are meant to be executed via 
[npx](https://blog.npmjs.org/post/162869356040/introducing-npx-an-npm-package-runner), and can be 
run without installing them locally. This ensures that the latest version of a generator is always
used.

The following sections describe the types of projects currently supported.

## [create-thrashplay-lib](https://github.com/thrashplay/thrashplay-app-creators/tree/master/packages/create-thrashplay-lib)

Quickstart: `npx create-thrashplay-lib`

This generator creates a new Typescript library project, structured as a monorepo containing 
smaller utility packages comprising the library. It is intended that an organization would have one
(or a small number) of these monorepo libraries, supporting any number of applications (which may
themselves be monorepos, or standalone packages).

If you instead want to create a single, standalone package (instead of a monorepo), then see the 
[TO BE DETERMINED] generator.

The new project will have default content for package.json, LICENSE, README.md, .gitignore. Lerna
will be configured in `independent` mode. Additional configuration will be generated, based on the
options you give to the generator script.

### Continuous Integration
The generator will ask what type of CI configuration to create. Based on your response, the new
project will have the following added:

#### Drone
If the `drone` CI option is selected, a `.drone.yml` will be created. The default drone configuration
will bootstrap, build, and test the project. If running on the _develop_ branch, it will publish a 
pre-release version of the project. If running on the _master_ branch, it will publish a normal
version of the project. 

For publishing to work, a Drone secret called `NPM_PUBLISH_TOKEN` must be
configured in Drone for the project. This will be added to `.npmrc` in the project build's workspace, and used
to authenticate with the NPM registry.

Additionally, if the "Slack" notifcation option was selected, an additional Drone secret called 
`SLACK_NOTIFICATION_WEBHOOK` must be added to the project. This is the webhook URL that Drone will use to send 
Slack messages. 


---
[![Generator](https://img.shields.io/badge/Generator-thrashplay--app--creators-blue)](https://github.com/thrashplay/thrashplay-app-creators)
[![lerna](https://img.shields.io/badge/maintained%20with-lerna-cc00ff.svg)](https://lerna.js.org/)