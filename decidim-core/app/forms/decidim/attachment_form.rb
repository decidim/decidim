# frozen_string_literal: true

module Decidim
  # A form object used to create attachments.
  #
  class AttachmentForm < Form
    attribute :title, String
    attribute :file

    mimic :attachment

    validates :title, presence: true, if: ->(form) { form.file.present? }
    validates :file, file_size: { less_than_or_equal_to: ->(form) { form.maximum_attachment_size } }

    def maximum_attachment_size
      Decidim.organization_settings(current_organization).upload_maximum_file_size
    end
  end
end
