---
sh: "<% if (license) { %>node <%= createThrashplayLibScriptsDir %>/fetch-license.js <%= license %> > <%= projectDir %>/packages/<%= name %>/LICENSE <% } else { %>echo No license specified, skipping LICENSE generation.<% } %>"
---
