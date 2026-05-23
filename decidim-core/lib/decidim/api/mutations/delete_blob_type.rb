# frozen_string_literal: true

module Decidim
  module Core
    class DeleteBlobType < Api::DestroyResourceType
      description "deletes a blob"

      required_scopes "admin:read", "admin:write"

      type Decidim::Core::BlobType

      def authorized?(id:)
        blob = find_resource(id)
        raise Decidim::Api::Errors::MutationNotAuthorizedError, I18n.t("decidim.api.errors.unauthorized_mutation") unless super && allowed_to?(:delete, :blob, blob, context)

        true
      end

      private

      def find_resource(id = nil)
        context[:blob] ||= begin
          id ||= arguments[:id]
          ActiveStorage::Blob.find(id)
        end
      end
    end
  end
end
