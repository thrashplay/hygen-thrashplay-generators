#!/usr/bin/env sh

set -e
set -x

if [ -z "$(git status --porcelain)" ]; then
  echo "No changed files detected, skipping git push."
  exit 0
fi

if [ -z "$DRONE_COMMIT_SHA" ]; then
  echo "Refusing to force push, because no original commit SHA was provided."
  exit 1
fi

# for debugging sake, just log what's changed
git status

# Force push the tags and amended message.
git push --no-verify --follow-tags --force-with-lease=master:${DRONE_COMMIT_SHA} --set-upstream origin master
