# Linting

- JavaScript linting:

```bash
npm run lint
# Expected time: ~6 seconds
# May show warnings about React version and import paths - this is normal
```

- Ruby linting:

```bash
bundle exec rubocop
# Expected time: ~1.5 seconds
# Use --parallel for faster execution
# Use -a flag for auto-correction
```

- ERB linting:

```bash
bundle exec erblint --lint-all
# use --autocorrect flag for auto-correction
```

- CSS/SCSS linting:

```bash
npm run stylelint
npm run prettier
# Use npm run prettify to fix formatting
```

- Normalize and sort translation keys:

```bash
bundle exec i18n-tasks normalize --locales en
```
