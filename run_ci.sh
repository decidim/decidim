!/bin/bash
set -ev
if [ "$GEM" == "." ]; then
  yarn test:ci
  docker build --rm=false -t codegram/decidim .
elif [ -f "run_ci.sh" ]; then
  sh ./run_ci.sh
fi

bundle exec rake
