# frozen_string_literal: true

module Decidim
  module Core
    class DeleteBlobType < Api::DestroyResourceType
      description "deletes a blob"

      type Decidim::Core::BlobType

      def authorized?(id:)
        blob = find_resource(id)
        super && allowed_to(:delete, :blob, blob, context, scope: :admin)
      end

      private

      def find_resource(id = nil)
        context[:blob] ||= begin
          id ||= arguments[:id]
          ActiveStorage::Blob.find_by(id:)
        end
      end
    end
  end
end
