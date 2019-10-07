---
to: "<%= projectDir %>/lerna.json"
---
{
  "command": {
    "version": {
      "allowBranch": "master",
      "message": "chore(release): publish latest versions"
    }
  },
  "ignore-changes": [
    "**/*.md",
    "**/*.test.ts",
    "**/_templates/**"
  ],
  "packages": [
    "packages/*"
  ],
  "version": "independent"
}