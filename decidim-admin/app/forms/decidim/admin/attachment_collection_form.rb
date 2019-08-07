# frozen_string_literal: true

module Decidim
  module Admin
    # A form object to create or update attachment collections.
    class AttachmentCollectionForm < Form
      include TranslatableAttributes

      translatable_attribute :name, String
      translatable_attribute :description, String
      attribute :weight, Integer, default: 0

      mimic :attachment_collection

      validates :name, :description, translatable_presence: true
    end
  end
end
