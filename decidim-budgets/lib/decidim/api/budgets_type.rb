# frozen_string_literal: true

module Decidim
  module Budgets
    class BudgetsType < Decidim::Api::Types::BaseObject
      implements Decidim::Core::ComponentInterface

      graphql_name "Budgets"
      description "A budget component of a participatory space."

      field :budgets, Decidim::Budgets::BudgetType.connection_type, null: true, connection: true

      def budgets
        Budget.where(component: object).includes(:component)
      end

      field :budget, Decidim::Budgets::BudgetType, null: true do
        argument :id, GraphQL::Types::ID, required: true
      end

      def budget(**args)
        Budget.where(component: object).find_by(id: args[:id])
      end
    end
  end
end
