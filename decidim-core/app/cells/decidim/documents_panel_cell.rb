# frozen_string_literal: true

module Decidim
  # This cell is used to render the documents panel of a resource
  # inside a tab of a show view
  #
  # The `model` must be a resource to get the documents from.and is expected to
  # respond to documents method
  #
  # Example:
  #
  #   cell(
  #     "decidim/documents_panel",
  #     meeting
  #   )
  class DocumentsPanelCell < Decidim::ViewModel
    include Decidim::AttachmentsHelper
    include Cell::ViewModel::Partial
    include ActiveSupport::NumberHelper
    include ERB::Util

    alias resource model

    def show
      return if blank?

      render
    end

    def documents
      @documents ||= resource.try(:documents)
    end

    def components_collections
      @components_collections ||= options[:components_collections] || []
    end

    def blank?
      documents.blank? && components_collections.blank?
    end
  end
end
