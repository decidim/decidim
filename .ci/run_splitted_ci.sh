#!/usr/bin/env bash

case $CIRCLE_NODE_INDEX in
  0)
    (yarn lint && bundle exec rspec spec) &&
    (yarn test -- decidim-api) &&
    (cd decidim-api && bundle exec rake) &&
    (yarn test -- decidim-core) &&
    (cd decidim-core && bundle exec rake)
    ;;
  1)
    (yarn test -- decidim-admin) &&
    (cd decidim-admin && bundle exec rake) &&
    (yarn test -- decidim-meetings) &&
    (cd decidim-meetings && bundle exec rake)
    ;;
  2)
    (yarn test -- decidim-proposals) &&
    (cd decidim-proposals && bundle exec rake) &&
    (yarn test -- decidim-comments) &&
    (cd decidim-comments && bundle exec rake)
    ;;
  3)
    (yarn test -- decidim-pages) &&
    (cd decidim-pages && bundle exec rake) &&
    (yarn test -- decidim-system) &&
    (cd decidim-system && bundle exec rake) &&
    (yarn test -- decidim-results) &&
    (cd decidim-results && bundle exec rake) &&
    (yarn test -- decidim-budgets) &&
    (cd decidim-budgets && bundle exec rake) &&
    (yarn test -- decidim-surveys) &&
    (cd decidim-surveys && bundle exec rake)
    ;;
esac
