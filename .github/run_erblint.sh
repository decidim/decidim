#!/bin/bash

shopt -s globstar

CURRENT_BRANCH=$(git branch --show-current)
DEFAULT_BRANCH=$(basename $(git symbolic-ref refs/remotes/origin/HEAD --short))

ALL_VIEWS=decidim**/app/{cells,views}/**/*.erb
MODIFIED_VIEWS=$(git diff --name-only "${DEFAULT_BRANCH}" | grep -E '(views|cells)/.*\.erb$')

# Scan only the modified ERB files, except for the default branch
FILES=$([[ "${CURRENT_BRANCH}" == "${DEFAULT_BRANCH}" ]] && echo ${ALL_VIEWS} || echo ${MODIFIED_VIEWS})
[[ -n "$FILES" ]] && bundle exec erblint ${FILES} || echo "No ERB files changed"

# Store the return code of the erblint execution
EXIT_CODE=$?

shopt -u globstar

exit $EXIT_CODE
