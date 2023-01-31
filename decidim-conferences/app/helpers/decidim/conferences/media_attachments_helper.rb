# frozen_string_literal: true

module Decidim
  # A Helper to render and link to resources.
  module Conferences
    module MediaAttachmentsHelper
      # Renders the attachment's title.
      # Checks if the attachment's title is translated or not and use
      # the correct render method.
      #
      # attachment - An Attachment object
      #
      # Returns String.
      def attachment_title(attachment)
        attachment.title.is_a?(Hash) ? translated_attribute(attachment.title) : attachment.title
      end
    end
  end
end
