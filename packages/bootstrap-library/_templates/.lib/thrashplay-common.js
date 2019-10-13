const _ = require('lodash')
const path = require('path')
const appRoot = require('app-root-path')

const getPackageName = (packageJson) => {
  const nameParts = _.get(packageJson, 'name').split('/')
  return nameParts.length > 1 ? nameParts[1] : nameParts[0]
}

const parsePackageJson = () => {
  try {
    const packageJsonPath = path.resolve(process.cwd(), 'package.json')
    console.info('looking for pkg.json:', packageJsonPath)
    if (fs.existsSync(packageJsonPath)) {
      const packageJson = require(packageJsonPath)
      console.info('thank god')
      return {
        packageLicense: _.get(packageJson, 'license'),
        packageName: getPackageName(packageJson),
      }
    } else {
      console.warn('not found')
    }
  } catch (err) {
    console.error('error:', err)
  }
  return {}
}

module.exports = {
  withDefaultArguments: (args) => _.merge({}, args, {
    ...parsePackageJson(),
    createThrashplayLibScriptsDir: path.resolve(appRoot.path, 'node_modules', '@thrashplay/bootstrap-library', 'dist'),
    projectDir: path.resolve(process.cwd()),
    ...args,
  })
}