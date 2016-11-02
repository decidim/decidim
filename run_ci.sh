#!/bin/bash
set -ev
if [ "$GEM" == "." ]; then
  docker build --rm=false -t AjuntamentdeBarcelona/decidim .
fi

bundle exec rake
