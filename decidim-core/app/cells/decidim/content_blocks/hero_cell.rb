# frozen_string_literal: true

module Decidim
  module ContentBlocks
    class HeroCell < Decidim::ViewModel
      include Decidim::CtaButtonHelper

      # Needed so that the `CtaButtonHelper` can work.
      def decidim_participatory_processes
        Decidim::ParticipatoryProcesses::Engine.routes.url_helpers
      end

      def translated_welcome_text
        translated_attribute(model.settings.welcome_text)
      end

      def background_image
        model.images_container.attached_uploader(:background_image).variant_url(:big)
      end

      private

      # A MD5 hash of model attributes because is needed because
      # the model does not respond to cache_key_with_version nor updated_at method
      def cache_hash
        hash = []
        hash << "decidim/content_blocks/hero"
        hash << Digest::SHA256.hexdigest(model.attributes.to_s)
        hash << current_organization.cache_key_with_version
        hash << I18n.locale.to_s
        hash << background_image

        hash.join(Decidim.cache_key_separator)
      end
    end
  end
end
