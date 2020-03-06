# Decidim GitHub Actions workflows

We use GitHub Actions as CI.

- `lint_code.yml`: runs the linters for Ruby, JS and ERB files.
- `ci_main.yml`: runs the tests for the main folder
- `ci_core.yml`: Runs the tests for eh `decidim-core` module. This workflow serves as a template for the rest of modules, since setup is mostly the same. In order to make changes, `cd` into the workflows folder and run `ruby generate_workflows.rb`.

Individual workflows with changes:

- `ci_generators.yml`: Does not need to create the test app, so this command is removed. Screenshots uploads and chromedriver setup steps are also removed. We also set `bundle config --local path ../vendor/bundle` after running `bundle install`:

```yml
# ci_generators.yml
- run: bundle install --path vendor/bundle --jobs 4 --retry 3
  name: Install Ruby deps
- run: bundle config --local path ../vendor/bundle
  working-directory: ${{ env.DECIDIM_MODULE }}
- run: bundle exec rake
  name: RSpec
  working-directory: ${{ env.DECIDIM_MODULE }}
```
