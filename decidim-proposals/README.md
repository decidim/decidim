# Decidim::Proposals

The Proposals module adds one of the main components of Decidim: allows users to contribute to a participatory process by creating proposals.

## Usage

Proposals will be available as a Component for a Participatory Process.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'decidim-proposals'
```

And then execute:

```bash
bundle
```

### Configuring Similarity

`pg_trgm` is a PostgreSQL extension providing simple fuzzy string matching used in the Proposal wizard to find similar published proposals (title and the body).

Create config variables in your app's `/config/initializers/decidim-proposals.rb`:

```ruby
Decidim::Proposals.configure do |config|
  config.similarity_threshold = 0.25 # default value
  config.similarity_limit = 10 # default value
end
```

`similarity_threshold`(real): Sets the current similarity threshold that is used by the % operator. The threshold must be between 0 and 1 (default is 0.3).

`similarity_limit`: number of maximum results.

## Contributing

See [Decidim](https://github.com/decidim/decidim).

## License

See [Decidim](https://github.com/decidim/decidim).
