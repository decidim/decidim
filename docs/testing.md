# How to test Decidim engines

## Requirements

You need to create a dummy application to run your tests. Run the following command in the decidim root's folder:

```bash
bundle exec rake decidim:generate_test_app
```

## Running the test suite

A Decidim engine can be tested running the following command inside its folder:

```bash
bundle exec rake
```
