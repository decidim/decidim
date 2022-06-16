# Decidim GitHub Actions workflows

We use GitHub Actions as CI.

- `lint_code.yml`: runs the linters for Ruby, JS and ERB files.
- `ci_main.yml`: runs the tests for the main folder
- `ci_core.yml`: runs the tests for the `decidim-core` module. The remaining workflows (except noted) are based on this one.

Individual workflows with changes:

- `ci_generators.yml`: `decidim-generators` does not need to create the test_app, so this command is removed. Screenshots uploads and chromedriver setup steps are also not needed for this module and thus removed. We also customize the gems path after running `bundle install`:

```yml
# ci_generators.yml
- run: bundle install --path vendor/bundle --jobs 4 --retry 3
  name: Install Ruby deps
- run: cp -R vendor/bundle decidim-generators
- run: bundle exec rspec
  name: RSpec
  working-directory: ${{ env.DECIDIM_MODULE }}
```

- `ci_comments.yml`: Runs tests for the JS files. Tests must run from the project root folder. You'll need to install NodeJS and the JS dependencies:

```yml
- uses: actions/setup-node@master
  with:
    node-version: ${{ env.NODE_VERSION }}
- run: npm ci
  name: Install JS deps
- run: npm run test
  name: Test JS files
```

- Some specs are split in three workflows, so if we need to retry this particular workflow we don't need to retry all the module suite. For instance proposals:

  - `ci_proposals_system_admin.yml`: Runs the system specs for the admin section
  - `ci_proposals_system_public.yml`: Runs the system specs for the public section
  - `ci_proposals_unit_tests.yml`: Runs the unit tests

- `ci_performance_metrics_monitoring.yml`: Runs Lighthouse metrics expectations against the app to detect any performance regression. The expectations can be found in `lighthouse_budget.json`, where a time is defined for each metric:

  - [First Contentful Paint](https://web.dev/first-contentful-paint/): 2 seconds
  - [Speed Index](https://web.dev/speed-index/): 4 seconds
  - [Time to Interactive](https://web.dev/interactive/): 5 seconds
  - [Largest Contentful Paint](https://web.dev/lcp/): 2.5 seconds
