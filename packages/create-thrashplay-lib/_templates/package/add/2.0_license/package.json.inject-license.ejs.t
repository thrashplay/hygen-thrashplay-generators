---
inject: true
to: <%= projectDir %>/packages/<%= name %>/package.json
before: dependencies
skip_if: "license"
eof_last: "false"
---
<%_ if (license) { %>  "license": "<%= license %>",<% } -%>