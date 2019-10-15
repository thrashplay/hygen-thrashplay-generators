#!/usr/bin/env sh

npx lerna exec --stream --no-bail --concurrency 1 -- PKG_VERSION=$(npm v . dist-tags.${1}); [ -n "$PKG_VERSION" ] && [ "LERNA_ROOT_PATH" != "`pwd`" ] && ( npm dist-tag add ${LERNA_PACKAGE_NAME}@${PKG_VERSION} ${2} )
