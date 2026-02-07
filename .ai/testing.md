# Testing

We use RSpec as technology for testing.

## Creating the Test App

As decidim is a gem, we need to create a rails application to run the tests. That's why we have the `spec/decidim_dummy_app`. When you generate it, you create a rails application with the decidim gem using the local files. You only need to generate it once. So if the directory already exists you don't need to generate it again unless a reset is required.

You should not change anything inside this test app as it's a local directory that won't be persisted.

```bash
# Install dependencies first (if not already done)
bundle install
npm install

# Create test app (generates spec/decidim_dummy_app)
bundle exec rake test_app
```

## Running tests

**NEVER CANCEL TESTS** - They may take several minutes to complete.

- Main test suite (1 minute 49 seconds - NEVER CANCEL):

```bash
bundle exec rspec
# Expected time: ~109 seconds - NEVER CANCEL
# Set timeout to 300+ seconds
```

- JavaScript tests (13 seconds):

```bash
npm run test
# Expected time: ~13 seconds
# Some vendor test failures are expected (shakapacker dependencies)
```

- Individual module tests:

```bash
bundle exec rake test_core        # Test decidim-core
bundle exec rake test_admin       # Test decidim-admin
bundle exec rake test_proposals   # Test decidim-proposals
# Each module test can take 10-30 minutes - NEVER CANCEL
```

- Individual test:

```bash
# You need to access the module where the test belong
# and run the rspec from there. For example:
cd decidim-core
bundle exec rspec spec/system/account_spec.rb
```

## Creating or updating tests

When you create or update any of the components described in `.ai/app-directories.md` you should create or update unit tests for them.

We also have `system` specs for integration specs. We shouldn't test all the scenarios there. Only the most relevant ones.

You can make use of the `shared_examples`, `shared_context`, etc. directives to avoid repeating code in your test files.

## System Tests Requirements

Some specs (especially `spec/system`) use Capybara with a real browser.

Requirements for running system tests locally:

- Google Chrome must be installed and available in `PATH`
- Google ChromeDriver should also be available
- ChromeDriver should have the same version number as Google Chrome
- The test app must be generated (`spec/decidim_dummy_app`)
- Tests are executed against the dummy app; do not modify it manually

If Chrome is missing, system specs will fail with driver or browser-related errors.

Chrome is required both locally and in CI for running system tests.
