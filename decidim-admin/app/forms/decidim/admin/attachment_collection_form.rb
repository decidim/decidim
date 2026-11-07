# frozen_string_literal: true

module Decidim
  module Admin
    # A form object to create or update attachment collections.
    class AttachmentCollectionForm < Form
      include TranslatableAttributes

      translatable_attribute :name, String
      translatable_attribute :description, String
      attribute :weight, Integer, default: 0
      attribute :key, String

      mimic :attachment_collection

      validates :name, :description, translatable_presence: true
      validate :key_uniqueness

      def key=(value)
        super(value&.strip)
      end

      private

      def key_uniqueness
        return if key.blank?
        return unless context&.collection_for

        existing = context.collection_for.attachment_collections.where(key:).where.not(id:).first

        errors.add(:key, :taken) if existing
      end
    end
  end
end
