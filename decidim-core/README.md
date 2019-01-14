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

## Amendments

Core implements an Amendment feature that can be activated in the components. As of now, it's only implemented in the proposal component.

This feature makes it possible for anyone to edit the text of an amendable resource and create a child resource as an amendment. This child resource may receive support and the author of the amendable resource may accept or reject the amendment (or child proposal). In case of rejection, the author of the rejected emendation may raise the child resource to an independent resource.

### Key artifacts for Amendments

- `Amendable` module: A concern with the features needed when you want a model to be amendable.
- `Amendment` class: The ApplicationRecord that includes the polymorphic associations to make the model amendable.

Models that want to be amendable must include `Amendable` and declare an `amendable` configuration for the model.

## Global Search

Core implements a Search Engine that indexes models from all modules globally.
This feature is implemented using [PostgreSQL capability for full text search](https://www.postgresql.org/docs/current/static/textsearch.html) via [`pg_search` gem](https://github.com/Casecommons/pg_search).

This module also includes the following models to Decidim's Global Search:

- `Users`

### Key artifacts for Global Search

- `Searchable` module: A concern with the features needed when you want a model to be searchable.
- `SearchableResource` class: The ActiveRecord that finally includes PgSearch and maps the indexed documents into a model.

Models that want to be indexed must include `Searchable` and declare `Searchable.searchable_fields`.

## Metrics docs

Core adds an implementation to show APP metrics within some pages. You can see specific documentation at [Metrics](https://github.com/decidim/decidim/tree/master/docs/advanced/metrics.md)

## Contributing

See [Decidim](https://github.com/decidim/decidim).

## License

See [Decidim](https://github.com/decidim/decidim).
