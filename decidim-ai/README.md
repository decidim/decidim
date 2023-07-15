# Decidim::Ai

The Decidim::AI is a library that aims to privide Artificial Inteligence tools for Decidim. This plugin has been initially developed aiming to analyze the content and provide spam classification using Naive Bayes algorithm.
All AI related functionality provided by Decidim should be included in this same module.

## Installation

In order to install use this library, you need at least Decidim 0.25 to be installed.

Add this line to your application's Gemfile:

```ruby
gem "decidim-tools-ai"
```

And then execute:

```bash
bundle install
```

After that, add an initializer file inside your project, having the following content:

```ruby
# config/initializers/decidim_ai.rb
```

After the configuration is added, you need to run the below command, so that the reporting user is created.

```ruby
bundle exec rake decidim:spam:data:create_reporting_user
```

If you have an existing installation, you can use the below command to train the engine with your existing data:

```ruby
bundle exec rake decidim:spam:train:moderation
```

Add the queue name to `config/sidekiq.yml` file:

```yaml
:queues:
- ["default", 1]
- ["spam_analysis", 1]
# The other yaml entries
```

## Contributing

See [Decidim](https://github.com/decidim/decidim).

## License

See [Decidim](https://github.com/decidim/decidim).
