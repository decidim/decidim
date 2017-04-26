#!/bin/bash
set -ev
if [ "$GEM" == "." ]; then
  yarn lint
elif [ -f "run_ci.sh" ]; then
  yarn test -- $GEM
fi

cd $GEM && bundle exec rake
