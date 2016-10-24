#!/bin/bash
set -ev
if [ "$GEM" == "." ]; then
  docker build --rm=false -t codegram/decidim .
fi

eslint app/**/*.js
bundle exec rake
