# frozen_string_literal: true

module Decidim
  module Admin
    # A form object used to create attachments in a participatory process.
    #
    class AttachmentForm < Form
      include TranslatableAttributes

      attribute :file
      translatable_attribute :title, String
      translatable_attribute :description, String
      attribute :attachment_collection_id, Integer

      mimic :attachment

      validates :file, presence: true, unless: :persisted?
      validates :title, :description, translatable_presence: true
      validates :attachment_collection_id, inclusion: { in: :attachment_collection_ids }, allow_blank: true

      delegate :attached_to, to: :context, prefix: false

      def attachment_collections
        @attachment_collections ||= attached_to.attachment_collections
      end

      private

      def attachment_collection_ids
        @attachment_collection_ids ||= attachment_collections.pluck(:id)
      end
    end
  end
end
