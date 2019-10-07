---
sh: "<% if (licenseId) { %>npx fetch-license <%= licenseId %> > <%= projectDir %>/LICENSE <% } else { %>echo No license specified, skipping LICENSE generation.<% } %>"
---
