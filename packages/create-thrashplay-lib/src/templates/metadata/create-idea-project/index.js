const withDefaultArguments = require("../../.lib/thrashplay-common").withDefaultArguments

module.exports = {
  params: (args) => {
    return withDefaultArguments(args)
  }
}
