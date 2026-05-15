# frozen_string_literal: true

module Decidim
  module ContentBlocks
    class ParticipatorySpaceHeroCell < Decidim::ContentBlocks::BaseCell
      delegate :title, :attached_uploader, to: :resource

      def cta_text
        return unless model

        @cta_text ||= translated_attribute(model.settings.button_text).presence
      end

      def cta_path
        return unless model

        @cta_path ||= translated_attribute(model.settings.button_url).presence
      end

      def title_text
        decidim_escape_translated(title)
      end

      def subtitle_text
        return unless resource.respond_to?(:subtitle)

        decidim_escape_translated(resource.subtitle)
      end

      def image_path
        model.images_container.attached_uploader(:background_image).url
      end

      def has_cta?
        [cta_text, cta_path].all?
      end
    end
  end
end
