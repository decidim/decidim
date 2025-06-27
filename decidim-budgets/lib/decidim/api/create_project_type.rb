# frozen_string_literal: true

module Decidim
  module Budgets
    class CreateProjectType < Decidim::Api::Types::BaseObject
      description "Creates a budget"
      type Decidim::Budgets::BudgetType
    end
  end
end
