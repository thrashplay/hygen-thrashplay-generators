---
to: "<%= projectDir %>/commitlint.config.js.ejs.t"
---
const fs = require('fs')
const path = require('path')

const getPackages = () => {
  return fs.readdirSync(path.resolve('packages'))
    .filter(name => !name.startsWith('.'))
}

module.exports = {
  extends: [
    '@commitlint/config-conventional'
  ],
  rules: {
    "body-max-line-length": [2, 'always', 100],
    "footer-max-line-length": [2, 'always', 100],
    "header-case": [2, 'always', 'sentence-case'],
    "header-full-stop": [2, 'always', '.'],
    "header-max-length": [2, 'always', 100],
    "scope-case": [2, 'always', 'kebab-case'],
    "scope-enum": [2, 'always', getPackages()]
  }
}

