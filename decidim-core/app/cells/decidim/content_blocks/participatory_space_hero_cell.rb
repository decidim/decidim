# frozen_string_literal: true

module Decidim
  module ContentBlocks
    class ParticipatorySpaceHeroCell < Decidim::ContentBlocks::BaseCell
      include Decidim::SanitizeHelper
      include Decidim::TranslationsHelper
      include Decidim::TwitterSearchHelper

      delegate :title, :subtitle, :hashtag, to: :resource

      def cta_text
        return unless model

        @cta_text ||= translated_attribute(model.settings.button_text).presence
      end

      def cta_path
        return unless model

        @cta_path ||= translated_attribute(model.settings.button_url).presence
      end

      def title_text
        translated_attribute(title)
      end

      def subtitle_text
        translated_attribute(subtitle)
      end

      def image_path
        model.images_container.attached_uploader(:background_image).path
      end

      def has_hashtag?
        @has_hashtag ||= hashtag.present?
      end

      def has_cta?
        [cta_text, cta_path].all?
      end

      def escaped_hashtag
        return unless has_hashtag?

        @escaped_hashtag ||= decidim_html_escape(hashtag)
      end
    end
  end
end
