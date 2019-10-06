#!/usr/bin/env node

const _ = require('lodash')
const github = require('./github-api')

const handleError = (error) => {
    console.log('Failed to retrieve license:', args[0])
    console.log()

    console.log(error)
    process.exit(-1)
}

(async () => {
    await github.get('/licenses')
        .then((licenses) => {
            console.log(
                licenses
                    .map((license) => license['spdx_id'])
                    .join(', ')
            )
        })
        .catch((error) => {
            handleError(error)
        })
})()
