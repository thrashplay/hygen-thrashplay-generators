#!/usr/bin/env node

const _ = require('lodash')
const ncp = require('ncp').ncp

const path = require('path')
const appRoot = require('app-root-path')

/**
 * Adds all templates defined in `sourceDir` to `targetDir`
 */
const addTemplates = (sourceDir, targetDir) => {
    console.log('Adding all templates from', sourceDir, 'into', targetDir)

    ncp(sourceDir, targetDir, { stopOnErr: true }, (errs) => {
        if (errs) {
            console.error('Error installing templates:', errs)
            process.exit(-1)
        } else {
            console.log('Success.', '\n')
        }
    })
}

const main = () => {
    console.log('Installing Thrashplay templates...')

    const root = appRoot.path

    let sourceDir = path.resolve(__dirname, 'templates');
    let targetDir = path.resolve(root, '_templates');
    addTemplates(sourceDir, targetDir)

    console.log('To remove Thrashplay tempaltes: `uninstall-thrashplay-templates`')
}

main()
