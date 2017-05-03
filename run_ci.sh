#!/bin/bash
set -ev

if [ "$GEM" == "." ]; then
  yarn lint
  bundle exec rspec spec
else
  yarn test -- $GEM
  cd $GEM && bundle exec rake
fi
