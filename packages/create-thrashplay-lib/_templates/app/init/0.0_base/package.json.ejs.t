---
to: <%= projectDir %>/package.json
---
{
  "name": "<%= name %>",
  "version": "0.0.0",
  "description": "<%= description %>",
  "private": true,
  "scripts": {
    "bootstrap": "yarn lerna bootstrap",
    "build": "yarn clean && yarn lerna run build",
    "clean": "yarn lerna run clean",
    "release": "yarn lerna publish --yes --conventional-commits",
    "release:graduate": "yarn release --conventional-graduate",
    "release:pre": "yarn release --conventional-prerelease --preid ${PRERELEASE_ID} --dist-tag ${PRERELEASE_ID}",
    "test": "yarn lerna run test"
  },
  "dependencies": {
  },
  "devDependencies": {
    "app-root-path": "^2.2.1",
    "hygen": "^4.0.9",
    "lerna": "^3.16.4",
    "patch-package": "^6.2.0"
  }
}
