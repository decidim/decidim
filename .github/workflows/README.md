# Decidim GitHub Actions workflows

We use GitHub Actions as CI.

- `lint_code.yml`: runs the linters for Ruby, JS and ERB files.
- `ci_main.yml`: runs the tests for the main folder
- `ci_core.yml`: Runs the tests for eh `decidim-core` module. This workflow serves as a template for the rest of modules, since setup is mostly the same. In order to make changes, `cd` into the workflows folder and run `ruby generate_workflows.rb`.
