---
inject: true
to: "<%= cwd %>/package.json"
after: scripts
eof_last: "false"
---
    "bootstrap": "yarn lerna bootstrap",
    "build": "yarn lerna run build",
    "release": "yarn lerna publish --conventional-commits",
    "test": "yarn lerna run test",
