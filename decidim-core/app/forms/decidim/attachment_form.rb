# frozen_string_literal: true

module Decidim
  # A form object used to create attachments.
  #
  class AttachmentForm < Form
    attribute :title, String
    attribute :file

    mimic :attachment

    validates :title, presence: true, if: ->(form) { form.file.present? }
  end
end
