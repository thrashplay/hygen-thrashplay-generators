const _ = require('lodash')
const path = require('path')
const appRoot = require('app-root-path')
const packageJson = require(path.resolve(process.cwd(), 'package.json'))

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

module.exports = {
  withDefaultArguments: (args) => _.merge({}, args, {
    createThrashplayLibVersion: getPackageVersion(),
    createThrashplayLibScriptsDir: path.resolve(appRoot.path, 'node_modules', '@thrashplay/bootstrap-library', 'dist'),
    projectDir: path.resolve(process.cwd()),
    packageLicense: fromPackageJson('license'),
    packageName: getPackageName(),
    ...args,
    templateSourceDir: path.resolve(appRoot.path, 'node_modules', '@thrashplay/bootstrap-library', 'dist', 'templates'),
  })
}