---
inject: true
to: "<%= cwd %>/package.json"
after: dependencies
eof_last: "false"
sh: "<%= packageManager %> install && lerna bootstrap"
---
    "lerna": "^3.16.4",
