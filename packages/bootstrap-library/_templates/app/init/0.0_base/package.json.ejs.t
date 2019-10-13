---
to: <%= projectDir %>/package.json
---
{
  "name": "<%= name %>",
  "version": "0.0.0",
  "description": "<%= description %>",
  "workspaces": [
    "packages/*"
  ],
  "private": true,
  "scripts": {
    "bootstrap": "yarn lerna bootstrap",
    "build": "yarn clean && yarn lerna run build",
    "clean": "yarn lerna run clean",
    "lint": "eslint --cache --report-unused-disable-directives \"**/*.ts\" \"**/*.js\" \"**/*.json\" \"scripts/*\"",
    "release": "yarn lerna publish --yes --conventional-commits",
    "release:graduate": "yarn release --conventional-graduate",
    "release:pre": "yarn release --conventional-prerelease --preid ${PRERELEASE_ID} --dist-tag ${PRERELEASE_ID}",
    "test": "yarn lerna run test"
  },
  "dependencies": {
  },
  "devDependencies": {
    "@typescript-eslint/eslint-plugin": "^2.3.3",
    "@typescript-eslint/eslint-plugin-tslint": "^2.3.3",
    "@typescript-eslint/parser": "^2.3.3",
    "app-root-path": "^2.2.1",
    "eslint": "^6.5.1",
    "eslint-config-standard": "^14.1.0",
    "eslint-plugin-import": "^2.18.2",
    "eslint-plugin-json": "^1.4.0",
    "eslint-plugin-node": "^10.0.0",
    "eslint-plugin-promise": "^4.2.1",
    "eslint-plugin-standard": "^4.0.1",
    "hygen": "^4.0.9",
    "lerna": "^3.16.4",
    "patch-package": "^6.2.0",
    "tslint": "^5.20.0",
    "typescript": "^3.6.4"
  }
}
