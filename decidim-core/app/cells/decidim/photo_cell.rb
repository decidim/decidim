# frozen_string_literal: true

module Decidim
  # This cell renders the media link card for an instance of a MediaLink
  class PhotoCell < Decidim::ViewModel
    include Decidim::ApplicationHelper
    include Decidim::LayoutHelper
    include Decidim::SanitizeHelper

    def show
      render
    end

    private

    def index
      @options[:index]
    end

    def image_alt
      strip_tags(description) || strip_tags(translated_attribute(model.title)) || t("alt", scope: "decidim.application.photo")
    end

    def image_thumb
      image_tag model.thumbnail_url, alt: image_alt
    end

    def image_big
      image_tag model.big_url, alt: image_alt
    end

    def title
      decidim_html_escape(translated_attribute(model.title))
    end

    def short_description
      decidim_sanitize_editor html_truncate(description, length: 100, separator: "...")
    end

    def description
      translated_attribute(model.description)
    end
  end
end
