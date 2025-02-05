# frozen_string_literal: true

module Decidim
  module Budgets
    class BudgetsType < Decidim::Core::ComponentType
      graphql_name "Budgets"
      description "A budget component of a participatory space."

      field :budget, Decidim::Budgets::BudgetType, "A single Budget object", null: true do
        argument :id, GraphQL::Types::ID, required: true
      end
      field :budgets, Decidim::Budgets::BudgetType.connection_type, "A collection of Budgets", null: true, connection: true

      def budgets
        Budget.where(component: object).includes(:component)
      end

      def budget(**args)
        Budget.where(component: object).find_by(id: args[:id])
      end
    end
  end
end
