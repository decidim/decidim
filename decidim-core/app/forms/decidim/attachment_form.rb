# frozen_string_literal: true

module Decidim
  # A form object used to create attachments.
  #
  class AttachmentForm < Form
    attribute :title, String
    attribute :file

    mimic :attachment
  end
end
