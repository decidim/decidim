# Decidim::Sortitions

This module makes possible to select among a set of proposals by sortition.

## Usage

Simply include it in your Decidim instance.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'decidim-sortitions'
```

And then execute:

```bash
bundle
```

## Import migrations

After installing the gem you must import and execute the migrations bundled with the gem:

```bash
bundle exec rails decidim_sortitions:install:migrations
bundle exec rails db:migrate
```

## Contributing

See [Decidim](https://github.com/decidim/decidim).

## License

See [Decidim](https://github.com/decidim/decidim).
