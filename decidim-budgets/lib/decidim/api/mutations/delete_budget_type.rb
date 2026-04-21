# frozen_string_literal: true

module Decidim
  module Budgets
    class DeleteBudgetType < Api::SoftDeleteResourceType
      description "deletes a budget"

      type Decidim::Budgets::BudgetType

      def authorized?(id:)
        context[:trashable_deleted_resource] = object

        unless super && allowed_to?(:soft_delete, :budget, object, context, scope: :admin)
          raise Decidim::Api::Errors::MutationNotAuthorizedError, I18n.t("decidim.api.errors.unauthorized_mutation")
        end

        true
      end

      private

      def find_resource(_id)
        object
      end

      def trashable_deleted_resource_type
        :budget
      end
    end
  end
end
