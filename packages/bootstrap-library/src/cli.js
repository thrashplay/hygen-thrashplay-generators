#!/usr/bin/env node

const { runner } = require('hygen')
const Logger = require('hygen/lib/logger')
const path = require('path')
const defaultTemplates = path.resolve(__dirname, '..', '_templates')
const updateNotifier = require('update-notifier');
const pkg = require('./package.json');

const updateCheck = () => {
  updateNotifier({
    distTag: 'alpha',
    pkg,
    shouldNotifyInNpmScript: true,
    updateCheckInterval: 1000 * 60 * 10, // 10 minutes
  }).notify()
}

const main = () => {
  console.info('>>> @thrashplay/bootstrap-library version:', pkg.version)

  updateCheck()

  const arguments = process.argv.length < 3
    ? ['app', 'init']
    : process.argv.slice(2)

  runner(arguments, {
    templates: defaultTemplates,
    cwd: __dirname,
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

main(process.argv)