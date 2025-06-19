# frozen_string_literal: true

module Decidim
  module ContentBlocks
    class ParticipatorySpaceHeroCell < Decidim::ContentBlocks::BaseCell
      include Decidim::TwitterSearchHelper

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

      # If it is called from the landing page content block, use the background image defined there
      # Else, use the banner image defined in the space (for assemblies)
      def image_path
        return model.images_container.attached_uploader(:background_image).url if model.respond_to?(:images_container)

        attached_uploader(:banner_image).url
      end

      def has_cta?
        [cta_text, cta_path].all?
      end
    end
  end
end
