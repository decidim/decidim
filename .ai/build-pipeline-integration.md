# Build Pipeline Integration

**CI Requirements:** The `.github/workflows/` contain the production CI setup:

- Tests run on Ubuntu
- Requires PostgreSQL and Redis services
- Uses specific Ruby and Node versions
- Runs parallel tests across multiple modules
- **Each module CI can timeout at 30-60 minutes - NEVER CANCEL**

## Pre-Commit Checklist

Before committing, ALWAYS run:

```bash
npm run lint
bundle exec rubocop
bundle exec erblint --lint-all
bundle exec i18n-tasks normalize --locales en
bundle exec rspec
npm run test
```

## Troubleshooting

### JavaScript Lint Failures

```bash
# View errors
npm run lint

# Auto-fix what can be fixed
npm run lint -- --fix
```

### Ruby Lint Failures (RuboCop)

```bash
# View errors with details
bundle exec rubocop

# Auto-fix safe corrections
bundle exec rubocop -a

# Auto-fix including unsafe corrections (review changes afterward)
bundle exec rubocop -A
```

### ERB Lint Failures

```bash
# View errors
bundle exec erblint --lint-all

# Auto-fix
bundle exec erblint --lint-all --autocorrect
```

### CSS/SCSS Formatting Issues

```bash
# Check issues
npm run stylelint
npm run prettier

# Auto-fix
npm run prettify
```

### Translation Key Issues

```bash
# Normalize and sort keys (only English)
bundle exec i18n-tasks normalize --locales en

# Find missing keys
bundle exec i18n-tasks missing

# Find unused keys
bundle exec i18n-tasks unused
```

### Test Failures

**IMPORTANT:** When a test fails, always ask the user whether you should fix the test or fix the code that the test is validating. Do not assume which approach is correct.

1. **Read the error message carefully** - RSpec provides detailed failure information

2. **Run the specific failing test** to iterate faster:

```bash
cd decidim-<module>
bundle exec rspec spec/path/to/failing_spec.rb:LINE_NUMBER
```

- You can pass multiple line numbers: file.rb:12:34
- For failures in shared contexts/examples, always run the concrete example using its file:line from the failure output.
- Alternatively, run by example description:

```bash
bundle exec rspec spec/path/to/failing_spec.rb -e "example description"
```

1. **Check for flaky tests** - If a test passes when run individually but fails in the suite, it may be a test isolation issue

2. **Reset the test database** if you suspect data issues:

```bash
cd spec/decidim_dummy_app
bin/rails db:reset RAILS_ENV=test
```

1. **Check for missing dependencies** - Run `bundle install` and `npm install` if tests fail with load errors
