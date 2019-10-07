---
sh: "<% if (licenseId) { %>node <%= scriptsDir %>/fetch-license.js <%= licenseId %> > <%= projectDir %>/LICENSE <% } else { %>echo No license specified, skipping LICENSE generation.<% } %>"
---
