#!/bin/bash
set -ev

if [ "$GEM" == "." ]; then
  npm run lint
  bundle exec rspec spec
else
  npm test -- $GEM
  cd $GEM && bundle exec rake
fi
