---
to: "<%= projectDir %>/lerna.json"
---
{
  "command": {
    "version": {
      "allowBranch": ["master", "develop"],
      "message": "chore(release): publish latest versions [ci skip]"
    }
  },
  "ignore-changes": [
    "**/*.md",
    "**/*.test.ts",
    "**/_templates/**"
  ],
  "npmClient": "yarn",
  "useWorkspaces": true,
  "packages": [
    "packages/*"
  ],
  "version": "independent"
}