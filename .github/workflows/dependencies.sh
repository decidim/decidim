#!/usr/bin/env bash

# This script gathers all the dependencies for each decidim module in the repository.
# Run it located on the root folder of the repo to get the list of paths to add to each workflow.
# The output must be manually added to each module workflow, in the on.pull_request.paths zone.

for module in $(ls | grep decidim-)
do
  echo "$module:"
  echo '      - "*"'
  echo '      - ".github/**"'
  cat "$module/$module.gemspec" | grep -o "decidim-[^\"]*" | sort | uniq | sed 's/^\(.*\)$/      - \"\1\/**"/'
done
