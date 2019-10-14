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
  "dependencies": {
  },
  "devDependencies": {
    "@commitlint/cli": "^8.2.0",
    "@commitlint/config-conventional": "^8.2.0",
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
    "husky": "^3.0.9",
    "hygen": "^4.0.9",
    "lerna": "^3.16.4",
    "patch-package": "^6.2.0",
    "tslint": "^5.20.0",
    "typescript": "^3.6.4"
  }
  "husky": {
    "hooks": {
      "commit-msg": "commitlint -E HUSKY_GIT_PARAMS",
      "pre-commit": "yarn lint && yarn test",
      "pre-push": "yarn lint && yarn test"
    }
  },
  "scripts": {
    "bootstrap": "yarn lerna bootstrap",
    "build": "yarn clean && yarn lerna run build",
    "clean": "yarn lerna run clean",
    "lint": "echo No files in project to lint!",
    "publish:tagged": "yarn lerna publish from-git",
    "test": "echo No files in project to test!",
    "version:graduate": "yarn lerna version --conventional-graduate",
    "version:prerelease": "yarn lerna version --conventional-prerelease"
  },
}
