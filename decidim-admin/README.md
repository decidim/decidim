# Decidim::Admin

This library adds an administration dashboard so users can manage their
organization, participatory processes and all other entities.

## Usage

This will add an admin dashboard to manage an organization an all its entities.
It's included by default with Decidim.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'decidim-admin'
```

And then execute:

```bash
bundle
```

## Features

### Static pages

This feature allows an admin to create pages to serve static content. Some
example of this kind of pages could be:

* Terms and Conditions
* FAQ
* Accessibility guidelines
* About the project

All the pages can be created with I18n support and will be accessible as
`/pages/:page-slug`. You can link them at your website the same way you link
other Rails models: `pages_path("terms-and-conditions")`.

There are some pages that exist by default and cannot be deleted since there
are links to them inside the Decidim framework, see `Decidim::StaticPage` for
the default list.

## Contributing

See [Decidim](https://github.com/decidim/decidim).

## License

See [Decidim](https://github.com/decidim/decidim).
