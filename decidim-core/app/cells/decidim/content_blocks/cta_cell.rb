# frozen_string_literal: true

module Decidim
  module ContentBlocks
    class CtaCell < Decidim::ViewModel
      include Decidim::SanitizeHelper

      def translated_button_text
        @translated_button_text ||= translated_attribute(model.settings.button_text)
      end

      def translated_description
        @translated_description ||= decidim_sanitize(translated_attribute(model.settings.description))
      end

      def button_url
        @button_url ||= model.settings.button_url
      end

      def cta_button
        link_to translated_button_text, button_url, class: "button button--sc medium-6", title: translated_button_text
      end

      def background_image
        model.images_container.background_image.big.url
      end
    end
  end
end
