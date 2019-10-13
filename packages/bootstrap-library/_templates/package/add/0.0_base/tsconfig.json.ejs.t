---
to: <%= projectDir %>/packages/<%= name %>/tsconfig.json
---
{
  "extends": "../../tsconfig.settings.json",
  "compilerOptions": {
    "outDir": "./dist",
    "rootDir": "./src"
  },
  "include": ["src"]
}