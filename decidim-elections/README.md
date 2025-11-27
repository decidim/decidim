# Decidim::Elections

The Decidim::Elections is a component that allows users to setup non-cryptographic elections. Elections are basically polls/surveys with census access management built-in. This allows registered or non-registered users to directly participate in them.

## Installation

In order to install use this module, you need at least Decidim 0.31 to be installed.

To install this module, run in your console:

```bash
bundle add decidim-elections
```

And then execute:

```bash
bundle
bundle exec rails decidim_elections:install:migrations
bundle exec rails db:migrate
```

## Contributing

See [Decidim](https://github.com/decidim/decidim).

## License

See [Decidim](https://github.com/decidim/decidim).
