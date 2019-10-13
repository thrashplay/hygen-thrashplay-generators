const _ = require('lodash')
const lib = require("../../.lib/thrashplay-common")

const notEmpty = (value) => {
  return _.trim(value) !== ''
}

module.exports = {
  prompt: ({prompter, args}) => {
    return Promise.resolve()
      .then(() => prompter.prompt([
        {
          type: 'input',
          name: 'name',
          message: "Package Name:",
          validate: notEmpty,
        },
        {
          type: 'input',
          name: 'description',
          message: 'Package Description:',
        }
      ]))
      .then((answers) => _.merge({}, answers, lib.withDefaultArguments(args)))
  },
}
