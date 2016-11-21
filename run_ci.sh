#!/bin/bash
set -ev
if [ "$GEM" == "." ]; then
  docker build --rm=false -t codegram/decidim .
fi

if [ "$GEM" == "decidim-comments"]; then
  yarn
  npm test
fi

bundle exec rake
