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
        # A blank key is stored as NULL rather than an empty string: the unique
        # index on the key per holder considers an empty string a value, so two
        # key-less collections for the same holder would be rejected, while NULL
        # values are not duplicates of each other.
        super(value.presence&.strip)
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
