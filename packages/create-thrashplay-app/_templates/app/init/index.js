const _ = require('lodash')
const path = require('path')
const appRoot = require('app-root-path')
const github = require('@thrashplay/github-helpers')
const packageJson = require('../../../package.json');

const fromPackageJson = (path) => {
  return _.get(packageJson, path)
}

const getPackageName = () => {
  const nameParts = fromPackageJson('name').split('/')
  return nameParts.length > 1 ? nameParts[1] : nameParts[0]
}

const getPackageVersion = () => {
  return '^' + fromPackageJson('version')
}

const getLicenses = () => {
  return github.get('/licenses')
    .then((licenses) => {
      return licenses
        .sort((license1, license2) => ('' + license1['name']).localeCompare(license2['name']))
        .map((license) => ({
          message: license['name'],
          name: license['spdx_id'],
        })).concat([
          {
            role: 'separator',
          },
          {
            message: 'All rights reserved.',
            name: 'UNLICENSED',
          },
          {
            message: 'Other',
            name: 'OTHER',
          }
        ])
      })
}

const notEmpty =(value) => {
  return _.trim(value) !== ''
}

const getDerivedArgs = (args) => {
  if (!args) {
    throw new Error('no `args` were specified!')
  }

  return {
    createThrashplayAppVersion: getPackageVersion(),
    scriptsDir: path.resolve(appRoot.path, 'node_modules', 'create-thrashplay-app', 'dist',),
    projectDir: path.resolve(process.cwd(), args.name),
    packageName: getPackageName(),
    ...args,
    templateSourceDir: path.resolve(appRoot.path, 'node_modules', 'create-thrashplay-app', 'dist', 'templates'),
  }
}

module.exports = {
  prompt: ({prompter, args}) => {
    return getLicenses()
      .then((licenses) => prompter.prompt([
        {
          type: 'input',
          name: 'name',
          message: "Project Name:",
          validate: notEmpty,
        },
        {
          type: 'input',
          name: 'description',
          message: 'Description:',
        },
        {
          type: 'select',
          name: 'licenseId',
          message: "License:",
          choices: licenses,
          default: 'UNLICENSED',
        },
      ]))
      .then((answers) => _.merge({}, answers, getDerivedArgs(answers)))
      .then((answers) => {
        return prompter.prompt([
            {
              type: 'input',
              name: 'licenseId',
              message: 'License SPDX ID:',
              skip: answers['licenseId'] !== 'OTHER',
            }
          ])
          .then((newAnswers) => _.merge({}, answers, {
            licenseId: _.trim(newAnswers['licenseId'] !== '' ? newAnswers['licenseId'] : answers['licenseId'])
          }))
      })
  },
}
