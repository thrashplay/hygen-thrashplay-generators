#!/usr/bin/env node

const _ = require('lodash')
const fs = require('fs')

const path = require('path')
const appRoot = require('app-root-path')

getGeneratorNames = (rootDir) => {
    try {
        let files = fs.readdirSync(rootDir, {withFileTypes: true});
        return _.filter(files, (file) => file.isDirectory())
    } catch (e) {
        // rootDir does not exist, ignore (since it won't exist before first pre-install)
        return []
    }
}

const deleteIfEmpty = (dir) => {
    let directoryContents
    try {
        directoryContents = fs.readdirSync(dir)
    } catch (e) {
        // directory doesn't exist yet, do nothing
        return
    }

    if (directoryContents.length === 0) {
        // console.log('Removing directory:', dir)
        fs.rmdirSync(dir)
    } else {
        console.warn('Not deleting non-empty directory:', dir)
    }
}

const recursiveDelete = (dir, fileName) => {
    const filePath = path.resolve(dir, fileName)

    let stat
    try {
        stat = fs.statSync(filePath)
    } catch (e) {
        // file does not exist, that's fine since it may not have been added before the first install
        return
    }

    if (stat.isFile()) {
        // console.log('Removing file:', filePath)
        fs.unlinkSync(filePath)
    } else {
        _.forEach(fs.readdirSync(filePath), (file) => recursiveDelete(filePath, file))
        deleteIfEmpty(filePath)
    }
}

/**
 * Deletes all templates from `targetDir` that are defined in `sourceDir`.
 */
const deleteTemplates = (sourceDir, targetDir) => {
    _.forEach(_.map(getGeneratorNames(sourceDir), (file) => file.name),
        (fileName) => {
            recursiveDelete(targetDir, fileName)
        })
}

const main = () => {
    console.log('Uninstalling hygen generators defined by:', process.env.npm_package_name)

    const currentDirectory = appRoot.path

    let sourceDir = path.resolve(currentDirectory, 'node_modules', process.env.npm_package_name, 'templates');
    let targetDir = path.resolve(currentDirectory, '_templates');
    deleteTemplates(sourceDir, targetDir)
    deleteIfEmpty(targetDir)
}

main()
