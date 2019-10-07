#!/usr/bin/env node

const _ = require('lodash')
const fetch = require('node-fetch')

const headers = new fetch.Headers({ Accept: 'application/vnd.github.v3+json' })
exports.get = (path) => {
    return fetch('https://api.github.com' + path, { headers })
        .then((response) => {
            if (response.ok) {
                return response.json()
            } else {
                throw 'Received error code [' + response.status + '] while fetching URL: ' + 'https://api.github.com' + path
            }
        })
        .catch((error) => {
            throw error
        })
}

exports.getLicenseKey = (spdxId) => {
    return exports.get('/licenses')
        .then((licenses) => {
            return _.get(_.find(licenses, { 'spdx_id': spdxId }), 'key')
        })
}