#!/bin/bash
set -ev

if [ "$GEM" == "." ]; then
  yarn lint
  bundle exec rspec spec
else
  yarn test -- $GEM
  bundle exec rake decidim:generate_test_app
  cd $GEM && bundle exec rake
fi
