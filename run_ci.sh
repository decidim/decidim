#!/bin/bash
set -ev
if [ "$GEM" == "." ]; then
  docker build --rm=false -t codegram/decidim .
fi

yarn run test
bundle exec rake
