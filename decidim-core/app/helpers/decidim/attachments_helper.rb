# frozen_string_literal: true
module Decidim
  # A Helper to render and link to resources.
  module AttachmentsHelper
    # Renders a the attachments of a model that includes the
    # HasAttachments concern.
    #
    # attached_to - The model to render the attachments from.
    #
    # Returns nothing.
    def attachments_for(attached_to)
      render partial: "attachments", locals: { attached_to: attached_to }
    end
  end
end
