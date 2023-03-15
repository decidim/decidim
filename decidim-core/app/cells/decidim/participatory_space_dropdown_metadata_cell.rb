# frozen_string_literal: true

module Decidim
  class ParticipatorySpaceDropdownMetadataCell < Decidim::ViewModel
    include Decidim::SanitizeHelper

    private

    def nav_items
      []
    end

    def title
      decidim_html_escape(translated_attribute(model.try(:title) || model.try(:name) || ""))
    end
  end
end
