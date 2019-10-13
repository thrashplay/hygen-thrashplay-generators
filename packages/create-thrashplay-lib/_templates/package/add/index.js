const lib = require("../../.lib/thrashplay-common")

module.exports = {
  params: (args) => {
    return lib.withDefaultArguments(args)
  }
}
