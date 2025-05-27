# frozen_string_literal: true

module Decidim
  module ContentBlocks
    class HighlightedContentBannerCell < Decidim::ViewModel
      def show
        render
      end

      def translated_title
        translated_attribute model.settings.title
      end

      def translated_short_description
        translated_attribute model.settings.short_description
      end

      def translated_banner_action_title
        translated_attribute model.settings.action_button_title
      end

      def translated_banner_action_subtitle
        translated_attribute model.settings.action_button_subtitle
      end

      def background_image
        model.images_container.attached_uploader(:background_image).variant_url(:big)
      end
    end
  end
end
