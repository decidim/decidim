#!/bin/bash
set -ev
if [ "$GEM" == "." ]; then
  docker build --rm=false -t codegram/decidim .
elif [ -f "run_ci.sh" ]; then
  sh ./run_ci.sh
fi

bundle exec rake
