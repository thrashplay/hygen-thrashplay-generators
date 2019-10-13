---
sh: "<% if (locals.license) { %>node <%= createThrashplayLibScriptsDir %>/fetch-license.js <%= locals.license %> > <%= projectDir %>/packages/<%= name %>/LICENSE <% } else { %>echo No license specified, skipping LICENSE generation.<% } %>"
---
