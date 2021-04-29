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

- Proposals specs are split in three workflows:

  - `ci_proposals_system_admin.yml`: Runs the system specs for the admin section
  - `ci_proposals_system_public.yml`: Runs the system specs for the public section
  - `ci_proposals_unit_tests.yml`: Runs the unit tests
