const _ = require('lodash')
const path = require('path')
const appRoot = require('app-root-path')
const github = require('@thrashplay/github-helpers')
const helpers = require('../../.lib/thrashplay-node-generators.js')

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
  return {
    ...helpers.params(args),
    ...args,
    templateSourceDir: path.resolve(appRoot.path, 'dist', 'templates'),
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
