# frozen_string_literal: true

module Decidim
  module Conferences
    # This cell renders the media link card for an instance of a MediaLink
    class PhotoCell < Decidim::ViewModel
      include Decidim::ApplicationHelper
      include Decidim::SanitizeHelper

      def show
        render
      end

      private

      def index
        @options[:index]
      end

      def image_thumb
        image_tag model.thumbnail_url, alt: t("alt", scope: "decidim.conferences.photo.image.attributes")
      end

      def image_big
        image_tag model.big_url, alt: t("alt", scope: "decidim.conferences.photo.image.attributes")
      end

      def title
        translated_attribute model.title
      end

      def short_description
        decidim_sanitize_editor html_truncate(description, length: 100, separator: "...")
      end

      def description
        translated_attribute(model.description)
      end
    end
  end
end
