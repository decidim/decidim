# frozen_string_literal: true

module Decidim
  module Budgets
    class BudgetsType < Decidim::Api::Types::BaseObject
      implements Decidim::Core::ComponentInterface

      graphql_name "Budgets"
      description "A budget component of a participatory space."

      field :budgets, BudgetType.connection_type, null: true, connection: true

      def budgets
        BudgetsTypeHelper.base_scope(object).includes(:component)
      end

      field :budget, BudgetType, null: true do
        argument :id, ID, required: true
      end

      def budget(**args)
        BudgetsTypeHelper.base_scope(object).find_by(id: args[:id])
      end
    end

    module BudgetsTypeHelper
      def self.base_scope(component)
        Budget.where(component: component)
      end
    end
  end
end
