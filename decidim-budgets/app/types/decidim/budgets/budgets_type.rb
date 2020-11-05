# frozen_string_literal: true

module Decidim
  module Budgets
    BudgetsType = GraphQL::ObjectType.define do
      interfaces [-> { Decidim::Core::ComponentInterface }]

      name "Budgets"
      description "A budget component of a participatory space."

      connection :budgets, BudgetType.connection_type do
        resolve ->(component, _args, _ctx) {
                  BudgetsTypeHelper.base_scope(component).includes(:component)
                }
      end

      field(:budget, BudgetType) do
        argument :id, !types.ID

        resolve ->(component, args, _ctx) {
          BudgetsTypeHelper.base_scope(component).find_by(id: args[:id])
        }
      end
    end

    module BudgetsTypeHelper
      def self.base_scope(component)
        Budget.where(component: component)
      end
    end
  end
end
