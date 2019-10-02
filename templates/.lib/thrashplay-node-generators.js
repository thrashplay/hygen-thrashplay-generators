const _ = require('lodash')
const path = require('path')
const appRoot = require('app-root-path')
const packageJson = require('../../package.json');

const fromPackageJson = (path) => {
    return _.get(packageJson, path)
}

const getPackageName = () => {
    const nameParts = fromPackageJson('name').split('/')
    return nameParts.length > 1 ? nameParts[1] : nameParts[0]
}

module.exports = {
    params: ({args}) => {
        return {
            scriptsDir: path.resolve(appRoot.path, 'scripts'),
            projectDir: path.resolve(appRoot.path),
            packageName: getPackageName(),
        }
    }
}
