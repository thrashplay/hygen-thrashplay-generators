---
sh: "<% if (licenseId) { %>node <%= createThrashplayAppScriptsDir %>/fetch-license.js <%= licenseId %> > <%= projectDir %>/LICENSE <% } else { %>echo No license specified, skipping LICENSE generation.<% } %>"
---
