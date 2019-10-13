---
sh: "<% if (licenseId) { %>node <%= createThrashplayLibScriptsDir %>/fetch-license.js <%= licenseId %> > <%= projectDir %>/LICENSE <% } else { %>echo No license specified, skipping LICENSE generation.<% } %>"
---
