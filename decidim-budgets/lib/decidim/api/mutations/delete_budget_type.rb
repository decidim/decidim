# frozen_string_literal: true

module Decidim
  module Budgets
    class DeleteBudgetType < Api::SoftDeleteResourceType
      description "Deletes a budget"

      type Decidim::Budgets::BudgetType

      required_scopes "api:read", "admin:read", "admin:write"

      def authorized?(id:)
        budget = find_resource(id)

        context[:budget] = budget
        context[:trashable_deleted_resource] = budget

        unless super && allowed_to?(:soft_delete, :budget, budget, context)
          raise Decidim::Api::Errors::MutationNotAuthorizedError, I18n.t("decidim.api.errors.unauthorized_mutation")
        end

        true
      end

      def self.permission_chain(object)
        super.unshift(Decidim::Budgets::Admin::Permissions)
      end

      private

      def find_resource(id)
        Budget.where(component: current_component).find(id)
      end

      def trashable_deleted_resource_type
        :budget
      end
    end
  end
end
