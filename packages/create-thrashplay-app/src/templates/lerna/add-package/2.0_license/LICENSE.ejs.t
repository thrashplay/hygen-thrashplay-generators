---
sh: "<% if (locals.license) { %>node node_modules/hygen-thrashplay-node-lib/dist/fetch-license.js <%= locals.license %> > <%= projectDir %>/LICENSE <% } else { %>echo No license specified, skipping LICENSE generation.<% } %>"
---
