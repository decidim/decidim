# Change Log

## [Unreleased](https://github.com/decidim/decidim/tree/HEAD)

### Added

- **decidim-core**, **decidim-budgets**: Reminders for pending orders in budgets [#8621](https://github.com/decidim/decidim/pull/8621). To generate reminders:

```bash
bundle exec rake decidim:reminders:all
```

Or add cronjob:

```bash
4 0 * * * cd /home/user/decidim_application && RAILS_ENV=production bundle exec rake decidim:reminders:all
```

#### New Api Documentation engine
PR [\#8631](https://github.com/decidim/decidim/pull/8631) Replaces graphql-docs npm package with gem. In this PR we have also added 3 configurable paramaters:

```ruby
# defines the schema max_per_page to configure GraphQL pagination
Decidim::Api.schema_max_per_page = 50

# defines the schema max_complexity to configure GraphQL query complexity
Decidim::Api.schema_max_complexity = 5000

# defines the schema max_depth to configure GraphQL query max_depth
Decidim::Api.schema_max_depth = 15
```

The static documentation will be rendered into : ```app/views/static/api/docs``` which is being refreshed automatically when you will run ```rake decidim:upgrade```.

You can manually regenerate the docs by running: ```rake decidim_api:generate_docs```

### Changed

### Fixed

### Removed

## Previous versions

Please check [release/0.26-stable](https://github.com/decidim/decidim/blob/release/0.26-stable/CHANGELOG.md) for previous changes.

