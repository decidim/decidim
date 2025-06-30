# frozen_string_literal: true

module Decidim
  module Budgets
    autoload :ProjectType, "decidim/api/project_type"
    autoload :BudgetType, "decidim/api/budget_type"
    autoload :BudgetsType, "decidim/api/budgets_type"
    # mutations
    autoload :BudgetsMutationType, "decidim/api/mutations/budgets_mutation_type"
    autoload :BudgetMutationType, "decidim/api/mutations/budget_mutation_type"
    autoload :BudgetAttributes, "decidim/api/mutations/budget_attributes"
    autoload :CreateBudgetType, "decidim/api/mutations/create_budget_type"
    autoload :UpdateBudgetType, "decidim/api/mutations/update_budget_type"
    autoload :DeleteBudgetType, "decidim/api/mutations/delete_budget_type"
    autoload :CreateProjectType, "decidim/api/mutations/create_project_type"
    autoload :ProjectAttributes, "decidim/api/mutations/project_attributes"
  end
end
