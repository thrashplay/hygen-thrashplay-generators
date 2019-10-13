---
inject: true
to: <%= projectDir %>/package.json
before: dependencies
skip_if: "license"
eof_last: "false"
---
<%_ if (licenseId) { %>  "license": "<%= licenseId %>",<% } -%>