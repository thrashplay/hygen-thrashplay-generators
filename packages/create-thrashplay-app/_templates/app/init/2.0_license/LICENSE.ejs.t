---
sh: "<% if (licenseId) { %>node <%= scriptsDir %>/fetch-license <%= licenseId %> > <%= projectDir %>/LICENSE <% } else { %>echo No license specified, skipping LICENSE generation.<% } %>"
---
