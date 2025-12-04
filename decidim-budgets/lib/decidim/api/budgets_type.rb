# frozen_string_literal: true

module Decidim
  module Budgets
    class BudgetsType < Decidim::Core::ComponentType
      graphql_name "Budgets"
      description "A budget component of a participatory space."

      field :budget, Decidim::Budgets::BudgetType, "A single Budget object", null: true do
        argument :id, GraphQL::Types::ID, "The id of the Budget requested", required: true
      end
      field :budgets, Decidim::Budgets::BudgetType.connection_type, "A collection of Budgets", null: true, connection: true

      def budgets
        Budget.where(component: object).includes(:component)
      end

      def budget(id:)
        Decidim::Core::ComponentFinderBase.new(model_class: Budget).call(object, { id: }, context)
      end
    end
  end
end
