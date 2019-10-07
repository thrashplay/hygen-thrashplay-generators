---
sh: "<% if (locals.license) { %>node <%= createThrashplayAppScriptsDir %>/fetch-license.js <%= locals.license %> > <%= projectDir %>/packages/<%= name %>/LICENSE <% } else { %>echo No license specified, skipping LICENSE generation.<% } %>"
---
