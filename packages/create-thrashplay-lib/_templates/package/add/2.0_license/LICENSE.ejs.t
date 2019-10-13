---
sh: "<% if (packageLicense) { %>node <%= createThrashplayLibScriptsDir %>/fetch-license.js <%= packageLicense %> > <%= projectDir %>/packages/<%= name %>/LICENSE <% } else { %>echo No license specified, skipping LICENSE generation.<% } %>"
---
