#!/bin/bash

shopt -s globstar

DEFAULT_BRANCH=$(git symbolic-ref refs/remotes/origin/HEAD | sed 's@^refs/remotes/origin/@@')

# Scan only the modified ERB files
bundle exec erblint $(git diff --name-only "${DEFAULT_BRANCH}" | grep '.erb$')

# Store the return code of the erblint execution
EXIT_CODE=$?

shopt -u globstar

exit $EXIT_CODE
