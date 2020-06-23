# frozen_string_literal: true

module Decidim
  module ContentBlocks
    class HeroCell < Decidim::ViewModel
      include Decidim::CtaButtonHelper
      include Decidim::SanitizeHelper

      # Needed so that the `CtaButtonHelper` can work.
      def decidim_participatory_processes
        Decidim::ParticipatoryProcesses::Engine.routes.url_helpers
      end

      def translated_welcome_text
        translated_attribute(model.settings.welcome_text)
      end

      def background_image
        model.images_container.background_image.big.url
      end

      private

      def cache_hash
        "decidim/content_blocks/hero/#{Digest::MD5.hexdigest(model.attributes.to_s)}/#{current_organization.cache_version}"
      end
    end
  end
end
