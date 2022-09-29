#!/bin/bash

shopt -s globstar

DEFAULT_BRANCH=develop

# Scan only the modified ERB files
FILES=$(git diff --name-only "${DEFAULT_BRANCH}"..HEAD -- | grep '.erb$')
[[ -n "$FILES" ]] && bundle exec erblint ${FILES} || echo "No ERB files changed"

# Store the return code of the erblint execution
EXIT_CODE=$?

shopt -u globstar

exit $EXIT_CODE
