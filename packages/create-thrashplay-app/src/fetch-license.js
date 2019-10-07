#!/usr/bin/env node

const _ = require('lodash')
const github = require('./github-api')
const [,, ...args] = process.argv

if (args.length !== 1) {
    console.error()
    console.error('Usage: ./scripts/fetch-license.js <license-spdx-id>')
    console.error()

    process.exit(-1)
}

const handleError = (error) => {
    console.log('Failed to retrieve license:', args[0])
    console.log()

    console.log(error)
    process.exit(-1)
}

(async (spdxId) => {
    await github.getLicenseKey(spdxId)
        .then((licenseKey) => {
            if (!licenseKey) {
                throw 'Unknown license ID: ' + spdxId
            }
            return github.get('/licenses/' + licenseKey)
        })
        .then((json) => console.log(_.get(json, 'body')))
        .catch((error) => {
            handleError(error)
        })
})(args[0])
