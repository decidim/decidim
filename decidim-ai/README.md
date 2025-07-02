# Decidim::Ai

The Decidim::Ai is a library that aims to provide Artificial Intelligence tools for Decidim. This plugin has been initially developed aiming to analyze the content and provide spam classification using Naive Bayes algorithm.
All AI related functionality provided by Decidim should be included in this same module.

For more documentation on the AI tools API, please refer to [documentation](https://docs.decidim.org/en/develop/develop/ai_tools.html)

## Installation

In order to install use this module, you need at least Decidim 0.30 to be installed.

To install this module, run in your console:

```bash
bundle add decidim-ai
```

After that, configure your your application using the environment variables as presented in the [documentation](https://docs.decidim.org/en/develop/configure/environment_variables.html)

Then, you need to run the below command, so that the reporting user is created.

```ruby
bin/rails decidim:ai:spam:create_reporting_user
```

Then you can use the below command to train the engine with the module dataset:

```ruby
bin/rails decidim:ai:spam:load_module_dataset
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
