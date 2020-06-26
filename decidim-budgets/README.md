# Decidim::Budgets

The Budgets module adds budgets with projects related to them to any participatory process. It adds a CRUD engine to the admin and public views scoped inside the participatory space. Projects will link to related proposals and have a budget. The users should be able to distribute a budget between these projects.

## Usage

Budgets will be available as a Component for a Participatory Space.

This plugin provides:

* A CRUD engine to manage budgets.
* A CRUD engine to manage projects related to a budget.
* Participant orders with the projects
* Budgets workflow to add different rules for budget voting.
* Public views for budgets and projects.

## Installation

Add this line to your application's Gemfile:

```ruby
gem "decidim-budgets"
```

And then execute:

```bash
bundle
```

## Budget Workflows

# !todo: default workflows + adding a custom workflow


## Contributing

See [Decidim](https://github.com/decidim/decidim).

## License

See [Decidim](https://github.com/decidim/decidim).
