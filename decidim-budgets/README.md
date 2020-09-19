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
By default there are two workflows included in this module, `:one` and `:all` that can be found in the `lib/decidim/budgets/workflows/` directory, any app can add its own workflow.

### Adding a custom workflow

To add a custom workflow, create a workflow that inherits from the `base`, such as:

```rb
# lib/budgets_workflow_random.rb
class BudgetsWorkflowRandom < Decidim::Budgets::Workflows::Base
  # your code here ...
end
```

And then add it to the decidim initializer (`config/initializers/decidim_budgets.rb`):

```rb
require "budgets_workflow_random"
Decidim::Budgets.workflows[:random] = BudgetsWorkflowRandom
```

Also remember to add the translated name for the `:random` workflow.

As an example, the `BudgetsWorkflowRandom` (`decidim-generators/lib/decidim/generators/app_templates/budgets_workflow_random.rb`) workflow is added by the generator in the `development_app` and `test_app`.

## Contributing

See [Decidim](https://github.com/decidim/decidim).

## License

See [Decidim](https://github.com/decidim/decidim).
