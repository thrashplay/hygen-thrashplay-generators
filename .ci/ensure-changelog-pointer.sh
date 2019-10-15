#!/usr/bin/env sh

set -e
set -x

if [ -z "$(git tag -l "meta/changelog-pointer")" ]; then
    echo "No meta/changelog-pointer tag, tagging first commit in repository."
    git tag "meta/changelog-pointer" $(git log --reverse -n1 --pretty=format:"%H" --no-patch)
fi
