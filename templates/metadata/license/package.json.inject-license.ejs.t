---
inject: true
to: "<%= cwd %>/package.json"
before: dependencies
eof_last: "false"
---
<%_ if (locals.license) { %>  "license": "<%= license %>",<% } -%>