# frozen_string_literal: true

module Decidim
  module Accountability
    class DeleteResultType < Api::SoftDeleteResourceType
      description "Deletes a result"

      type Decidim::Accountability::ResultType

      required_scopes "admin:read", "admin:write"

      def authorized?(id:)
        result = find_resource(id)
        context[:trashable_deleted_resource] = result

        unless super && allowed_to?(:soft_delete, :result, result, context)
          raise Decidim::Api::Errors::MutationNotAuthorizedError, I18n.t("decidim.api.errors.unauthorized_mutation")
        end

        true
      end

      def self.permission_chain(object)
        super.unshift(Decidim::Accountability::Admin::Permissions)
      end

      private

      def find_resource(id)
        Decidim::Accountability::Result.where(component: current_component).find(id)
      end

      def trashable_deleted_resource_type
        :result
      end
    end
  end
end
