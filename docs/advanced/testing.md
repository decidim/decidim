# How to test Decidim engines

## Requirements

You need to create a dummy application to run your tests. Run the following command in the decidim root's folder:

```bash
bundle exec rake test_app
```

## Running a specific test file or just a single spec

If you are writing new specs, you can run the tests contained in a single file by opening a console window in the corresponding module and calling `rspec`on the file. For example:

```bash
cd decidim-participatory_processes
bundle exec rspec spec/forms/participatory_process_form_spec.rb
```

You can also run a single test by appending its start line number to the command:

```bash
bundle exec rspec spec/forms/participatory_process_form_spec.rb:134
```

## Running tests for a specific component

A Decidim engine can be tested running the rake task named after it. For
example, to test the proposals engine, you can run:

```bash
bundle exec rake test_proposals
```

## Running the whole test suite

You can also run the full thing including test application generation and tests
for all components by running

```bash
bundle exec rake test_all
```

But beware, it takes a long time... :)

## Make CircleCI not run tests for a specific commit

If you want that CircleCI no run tests for a specific commit, add this in your commit message `[ci_skip]`
