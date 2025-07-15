# frozen_string_literal: true

module Decidim
  module Budgets
    class DeleteBudgetType < Api::SoftDeleteResourceType
      description "deletes a budget"

      type Decidim::Budgets::BudgetType

      def authorized?(id:)
        budget = find_resource(id)
        context[:trashable_deleted_resource] = budget

        super && allowed_to?(:soft_delete, :budget, budget, context, scope: :admin)
      end

      private

      def find_resource(id)
        Decidim::Budgets::Budget.find_by(id:, component: object)
      end

      def trashable_deleted_resource_type
        :budget
      end
    end
  end
end
