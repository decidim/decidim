# frozen_string_literal: true

module Decidim
  module ContentBlocks
    class HeroCell < Decidim::ViewModel
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

      def cta_button_text
        translated_attribute(model.settings.cta_button_text).presence || t("decidim.pages.home.hero.participate")
      end

      def cta_button
        link_to cta_button_text, cta_button_path, class: "hero-cta button expanded large button--sc", title: t("decidim.pages.home.hero.participate_title")
      end

      def cta_button_path
        if model.settings.cta_button_path.present?
          translated_attribute(model.settings.cta_button_path)
        elsif Decidim::ParticipatoryProcess.where(organization: current_organization).published.any?
          decidim_participatory_processes.participatory_processes_path
        elsif current_user
          decidim.account_path
        elsif current_organization.sign_up_enabled?
          decidim.new_user_registration_path
        else
          decidim.new_user_session_path
        end
      end
    end
  end
end
