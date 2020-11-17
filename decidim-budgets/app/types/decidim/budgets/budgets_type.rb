# frozen_string_literal: true

module Decidim
  module Budgets
    class BudgetsType < GraphQL::Schema::Object
      graphql_name "Budgets"
      implements Decidim::Core::ComponentInterface
      description "A budget component of a participatory space."

      field :budgets, BudgetType.connection_type, null: false do
        def resolve(component, _args, _ctx)
          BudgetsTypeHelper.base_scope(component).includes(:component)
        end
      end
      field(:budget, BudgetType, null: true) do
        argument :id, ID, required: true

        def resolve(component, args, _ctx)
          BudgetsTypeHelper.base_scope(component).find_by(id: args[:id])
        end
      end
    end

    module BudgetsTypeHelper
      def self.base_scope(component)
        Budget.where(component: component)
      end
    end
  end
end
