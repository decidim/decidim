# frozen_string_literal: true

module Decidim
  module Core
    class DeleteAttachmentCollectionType < Api::DestroyResourceType
      description "deletes an attachment collection"

      type Decidim::Core::AttachmentType

      def authorized?(id:)
        attachment_collection = find_resource(id)
        super && allowed_to?(:destroy, :attachment_collection, attachment_collection, context, scope: :admin)
      end

      private

      def find_resource(id = nil)
        context[:attachment_collection] ||= begin
          id ||= arguments[:id]
          object.attachment_collections.find_by(id:)
        end
      end
    end
  end
end
