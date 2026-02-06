# decidim-conferences

Conferences are the permanent Decidim's participatory space.

A conference can get different components (such as blogs or proposals) attached.
It can also have attachments, be associated to custom categories or scopes, and
can be fully managed via an administration UI.

## Usage

This module provides:

* A CRUD engine to manage conferences.

* Public views for conference via a high level section in the main menu.

You can see the documentation of this feature at the [Decidim Documentation](https://docs.decidim.org/en/develop/admin/spaces/conferences).

## Installation

To install this module, run in your console:

```bash
bundle add decidim-conferences
bundle exec rails decidim:upgrade
bundle exec rails db:migrate
```

## Contributing

See [Decidim](https://github.com/decidim/decidim).

## License

See [Decidim](https://github.com/decidim/decidim).
