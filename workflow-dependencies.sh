#!/bin/bash

# This scripts uses the .gemspec files to gather all the dependencies for each decidim module in the repo.
# The output must be manually added to each module workflow, in the on.pull_request.paths zone.

for module in $(ls | grep decidim-)
do
  echo "$module:"
  echo '      - "*"'
  echo '      - ".github/**"'
  cat "$module/$module.gemspec" | grep -o "decidim-[^\"]*" | sort | uniq | sed 's/^\(.*\)$/      - \"\1\/**"/'
done
