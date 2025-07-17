# frozen_string_literal: true

module Decidim
  module Core
    class DeleteAttachmentType < Api::DestroyResourceType
      description "deletes an attachment"

      type Decidim::Core::AttachmentType

      def authorized?(id:)
        attachment = find_resource(id)
        super && allowed_to?(:delete, :attachment, attachment, context, scope: :admin)
      end

      private

      def find_resource(id = nil)
        context[:attachment] ||= begin
          id ||= arguments[:id]
          Decidim::Attachment.find_by(id:)
        end
      end
    end
  end
end
