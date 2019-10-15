#!/usr/bin/env sh

set -e
set -x

npx lerna exec --stream --no-bail --concurrency 1 -- PKG_VERSION=$(npm v . dist-tags.${1}); [ -n "$PKG_VERSION" ] && [ "${LERNA_ROOT_PATH}" != "`pwd`" ] && pwd && echo "aaa ${LERNA_ROOT_PATH}" && ( npm dist-tag add ${LERNA_PACKAGE_NAME}@${PKG_VERSION} ${2} )
