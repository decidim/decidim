# Decidim::Consultations

Decidim consultatios is a Decidim plugin that allows managing public consultations.

## Usage

This plugin provides:

* A CRUD engine to manage consultations.

* Public views for initiatives via a high level section in the main menu.

* An URL that can be used in conjunction with an iframe element in order to embed a consultation inside an external page.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'decidim-consultations'
```

And then execute:

```bash
bundle
bundle exec rails decidim_consultations:install:migrations
bundle exec rails db:migrate
```

## Embeding a consultation

In order to embed a consultation inside an external page we must use an iframe element. The url required to use it is
the same url for the consultation in Decidim but adding a '/embed' at the end. So for example if our consultation has
the following URL:

http://localhost:3000/consultations/sit-cumque

we should embed it using the following URL:

http://localhost:3000/consultations/sit-cumque/embed

Notice the '/embed' at the end of the URL.

## Contributing

See [Decidim](https://github.com/decidim/decidim).

## License

See [Decidim](https://github.com/decidim/decidim).
