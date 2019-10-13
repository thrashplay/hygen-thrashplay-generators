---
to: <%= projectDir %>/packages/<%= name %>/package.json
---
{
  "name": "<%= name %>",
  "version": "0.0.0",
  "description": "<%= description %>",
  "files": [
    "bin",
    "dist"
  ],
  "scripts": {
    "build": "echo No build tasks defined.",
    "clean": "echo No clean tasks defined",
    "test": "echo No test tasks defined."
  },
  "publishConfig": {
    "access": "public"
  },
  "dependencies": {
  },
  "devDependencies": {
  }
}
