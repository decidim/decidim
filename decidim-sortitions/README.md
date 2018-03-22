# Decidim::Sortitions
This module makes possible to select amont a set of proposal by sortition.

## Usage
Simply include it in your Decidim instance.

## Installation
Add this line to your application's Gemfile:

```ruby
gem 'decidim-sortitions'
```

And then execute:
```bash
$ bundle
```

Or install it yourself as:
```bash
$ gem install decidim-sortitions
```

## Import migrations

After installing the gem you must import and execute the migrations bundled with the gem:

```bash
$ bundle exec rails decidim_sortitions:install:migrations
$ bundle exec rails db:migrate
```
