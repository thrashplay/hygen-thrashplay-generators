#!/usr/bin/env sh

set -e
set -x

git tag -d "meta/changelog-pointer"
git tag -a "meta/changelog-pointer" -m "Bumping changelog pointer after release."

