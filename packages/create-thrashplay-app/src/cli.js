#!/usr/bin/env node

const { runner } = require('hygen')
const Logger = require('hygen/lib/logger')
const path = require('path')
const defaultTemplates = path.resolve(__dirname, '..', '_templates')

const main = () => {
  runner(process.argv.slice(2), {
    templates: defaultTemplates,
    cwd: process.cwd(),
    logger: new Logger(console.log.bind(console)),
    createPrompter: () => require('enquirer'),
    exec: (action, body) => {
      const opts = body && body.length > 0 ? {input: body} : {}
      const execa = require('execa').shell(action, opts);
      execa.stdout.pipe(process.stdout);
      return execa;
    },
    debug: !!process.env.DEBUG
  })
}

main()