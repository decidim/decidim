# frozen_string_literal: true
module Decidim
  module Admin
    # A form object used to create attachments in a participatory process.
    #
    class ParticipatoryProcessAttachmentForm < Form
      include TranslatableAttributes

      attribute :file
      translatable_attribute :title, String
      translatable_attribute :description, String

      mimic :participatory_process_attachment

      validates :file, presence: true, unless: :persisted?
      validates :title, :description, translatable_presence: true
    end
  end
end
