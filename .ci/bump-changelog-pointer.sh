#!/usr/bin/env sh

set -e
set -x

if [ -z "$(git tag -l "meta/changelog-pointer")" ]; then
    echo "No meta/changelog-pointer tag, tagging first commit in repository."
    git tag -a "meta/changelog-pointer" -m "Bumping changelog pointer after release."
fi
