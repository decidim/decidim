# Decidim::Ai

The Decidim::Ai is a library that aims to provide Artificial Intelligence tools for Decidim. This plugin has been initially developed aiming to analyze the content and provide spam classification using Naive Bayes algorithm.
All AI related functionality provided by Decidim should be included in this same module.

## Installation

In order to install use this module, you need at least Decidim 0.30 to be installed.

Add this line to your application's Gemfile:

```ruby
gem "decidim-ai"
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
bin/rails decidim:ai:create_reporting_user
```

Then you can use the below command to train the engine with the module dataset:

```ruby
bin/rails decidim:ai:load_module_dataset
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
