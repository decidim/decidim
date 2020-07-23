# Decidim::Budgets

The Budgets module adds budgets with projects related to them to any participatory process. It adds a CRUD engine to the admin and public views scoped inside the participatory space. Projects will link to related proposals and have a budget. The users should be able to distribute a budget between these projects.

## Usage

Budgets will be available as a Component for a Participatory Space.

This plugin provides:

* A CRUD engine to manage budgets.
* A CRUD engine to manage projects related to a budget.
* Participant orders with the voted projects
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

A budget workflow, let's an admin pick, at the component level, how a user can participate in it.
By default there are some workflows included in this module that can be found in the `lib/decidim/budgets/workflows/` directory, any app can add its own workflow.

To add a custom workflow, create a workflow that inherits from the `base`, such as:

```rb
# lib/decidim_app/budgets_workflow_2020.rb
module DecidimApp
  class BudgetsWorkflow2020 < Decidim::Budgets::Workflows::Base
    # your code here ...
  end
end
```

And then add it to the decidim initializer (`config/initializers/decidim.rb`):

```rb
require "decidim_app/budgets_workflow_2020"
Decidim::Budgets.workflows[:2020] = DecidimApp::BudgetsWorkflow2020
```

## Contributing

See [Decidim](https://github.com/decidim/decidim).

## License

See [Decidim](https://github.com/decidim/decidim).
