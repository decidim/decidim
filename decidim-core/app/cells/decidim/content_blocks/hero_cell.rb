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

      # A MD5 hash of model attributes because is needed because
      # the model doesn't respond to cache_version nor updated_at method
      def cache_hash
        hash = []
        hash << "decidim/content_blocks/hero"
        hash << Digest::MD5.hexdigest(model.attributes.to_s)
        hash << current_organization.cache_version
        hash << I18n.locale.to_s

        hash.join("/")
      end
    end
  end
end
