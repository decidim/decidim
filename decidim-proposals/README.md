# Decidim::Proposals

The Proposals module adds one of the main features of Decidim: allows users to contribute to a participatory process by creating proposals.

## Usage

Proposals will be available as a Feature for a Participatory Process.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'decidim-proposals'
```

And then execute:

```bash
bundle
```

## Configuring Similarity

Create config variables in your app's `/config/initializers/decidim-proposals.rb`:

```ruby
Decidim::Proposals.configure do |config|
  config.similarity_threshold = 0.25 # default value
  config.similarity_limit = 10 # default value
end
```

## Contributing

See [Decidim](https://github.com/decidim/decidim).

## License

See [Decidim](https://github.com/decidim/decidim).
