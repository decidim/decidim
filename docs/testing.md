# How to test Decidim engines

## Requirements

You need to install [chromedriver](https://sites.google.com/a/chromium.org/chromedriver/) to run feature specs.

## Running the test suite

A Decidim engine can be tested using a dummy application which can be created using the following command inside the engine folder:

```bash
bundle exec rake generate_test_app
```

Then, you can run the tests as usual using the `rspec` command:

```bash
bundle exec rspec spec
```

## Feature tests

Feature tests are executed using Selenium and Chromium. If you want to run your tests in `headless` mode and your default Chromium browser doesn't support it you can specify another Chromium binary like this:

```bash
CAPYBARA_CHROMIUM_BIN=/path/to/my/chromium bundle exec rspec spec
```