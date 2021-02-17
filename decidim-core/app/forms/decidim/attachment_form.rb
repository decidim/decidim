# frozen_string_literal: true

module Decidim
  # A form object used to create attachments.
  #
  class AttachmentForm < Form
    include Decidim::HasUploadValidations

    attribute :title, String
    attribute :file
    attribute :delete_file, Boolean

    mimic :attachment

    validates :title, presence: true, if: ->(form) { form.file.present? }
    validates :file, passthru: { to: Decidim::Attachment }, if: ->(form) { form.file.present? }

    alias organization current_organization
  end
end
