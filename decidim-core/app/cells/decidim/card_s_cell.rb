# frozen_string_literal: true

module Decidim
  # This cell is used a base for all Search cards. It holds the basic layout
  # so other cells only have to customize a few methods or overwrite views.
  class CardSCell < Decidim::ViewModel
    include Decidim::ApplicationHelper
    include Decidim::SanitizeHelper

    alias resource model

    def show
      render
    end

    private

    def resource_path
      resource_locator(resource).path
    end

    def metadata_cell
      nil
    end

    def title
      decidim_html_escape(translated_attribute(resource.title))
    end

    def title_tag
      options[:title_tag] || :h3
    end
  end
end
