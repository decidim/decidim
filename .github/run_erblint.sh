#!/bin/bash

shopt -s globstar

bundle exec erblint decidim**/app/{cells,views}/**/*.erb

# Store the return code of the erblint execution
EXIT_CODE=$?

shopt -u globstar

exit $EXIT_CODE
