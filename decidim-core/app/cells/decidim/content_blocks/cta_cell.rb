# frozen_string_literal: true

module Decidim
  module ContentBlocks
    class CtaCell < Decidim::ViewModel
      include Decidim::SanitizeHelper

      def show
        return if button_url.blank?

        render
      end

      def translated_button_text
        @translated_button_text ||= translated_attribute(model.settings.button_text)
      end

      def translated_description
        @translated_description ||= decidim_sanitize_editor_admin(translated_attribute(model.settings.description))
      end

      def button_url
        @button_url ||= model.settings.button_url
      end

      def background_image
        model.images_container.attached_uploader(:background_image).path(variant: :big)
      end
    end
  end
end
