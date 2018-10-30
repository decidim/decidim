# Decidim

Core functionality in Decidim. Every single decidim functionality depends on this gem.

## Usage

You'll be using indirectly on any decidim application.

## Installation

Add `decidim` to your `Gemfile` and you'll be using it:

```ruby
gem 'decidim'
```

And then execute:

```bash
bundle
```

## Global Search

Core implements a Search Engine that indexes models from all modules globally.
This feature is implemented using [PostgreSQL capability for full text search](https://www.postgresql.org/docs/current/static/textsearch.html) via [`pg_search` gem](https://github.com/Casecommons/pg_search).

This module also includes the following models to Decidim's Global Search:

- `Users`

### Key artifacts

- `Searchable` module: A concern with the features needed when you want a model to be searchable.
- `SearchableResource` class: The ActiveRecord that finally includes PgSearch and maps the indexed documents into a model.

Models that want to be indexed must include `Searchable` and declare `Searchable.searchable_fields`.

## Metrics docs

Core adds an implementation to show APP metrics within some pages. You can see specific documentation at [Metrics](https://github.com/decidim/decidim/tree/master/docs/advanced/metrics.md)

## Contributing

See [Decidim](https://github.com/decidim/decidim).

## License

See [Decidim](https://github.com/decidim/decidim).
