# frozen_string_literal: true

module Decidim
  module Accountability
    class DeleteResultType < Api::SoftDeleteResourceType
      description "deletes a result"

      type Decidim::Accountability::ResultType

      def authorized?(id:)
        context[:trashable_deleted_resource] = object

        unless super && allowed_to?(:soft_delete, :budget, object, context, scope: :admin)
          raise Decidim::Api::Errors::MutationNotAuthorizedError, I18n.t("decidim.api.errors.unauthorized_mutation")
        end

        true
      end

      def self.permission_chain(object)
        super.unshift(Decidim::Accountability::Admin::Permissions)
      end

      private

      def find_resource(_id)
        object
      end

      def trashable_deleted_resource_type
        :result
      end
    end
  end
end
