# frozen_string_literal: true

module Decidim
  # A Helper to render and link to resources.
  module AttachmentsHelper
    include IconHelper

    # Renders a the attachments of a model that includes the
    # HasAttachments concern.
    #
    # attached_to - The model to render the attachments from.
    def attachments_for(attached_to)
      return unless attached_to.is_a?(Decidim::HasAttachments)

      cell "decidim/tab_panels", attachments_tab_panel_items(attached_to)
    end

    def attachments_tab_panel_items(attached_to)
      [
        {
          enabled: attached_to.photos.any?,
          id: "images",
          text: t("decidim.application.photos.photos"),
          icon: resource_type_icon_key("images"),
          method: :cell,
          args: ["decidim/images_panel", attached_to]
        },
        {
          enabled: attached_to.documents.any?,
          id: "documents",
          text: t("decidim.application.documents.documents"),
          icon: resource_type_icon_key("documents"),
          method: :cell,
          args: ["decidim/documents_panel", attached_to]
        }
      ]
    end

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
