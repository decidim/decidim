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

      mimic :attachment

      validates :file, presence: true, unless: :persisted?
      validates :title, :description, translatable_presence: true
    end
  end
end
