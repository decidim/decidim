# frozen_string_literal: true

module Decidim
  module Budgets
    autoload :ProjectType, "decidim/api/project_type"
    autoload :BudgetType, "decidim/api/budget_type"
    autoload :BudgetsType, "decidim/api/budgets_type"
    autoload :BudgetsMutationType, "decidim/api/budgets_mutation_type"
    autoload :BudgetAttributes, "decidim/api/budget_attributes"
    autoload :CreateBudgetType, "decidim/api/create_budget_type"
    autoload :UpdateBudgetType, "decidim/api/update_budget_type"
  end
end
