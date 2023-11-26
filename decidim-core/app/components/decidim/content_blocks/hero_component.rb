# frozen_string_literal: true

module Decidim
  module ContentBlocks
    class HeroComponent < ContentBlockComponent

      class CtaButtonComponent < Decidim::BaseComponent
        include Decidim::CtaButtonHelper

        # Needed so that the `CtaButtonHelper` can work.
        def decidim_participatory_processes
          Decidim::ParticipatoryProcesses::Engine.routes.url_helpers
        end
      end

      private

      def cta_button
        render(CtaButtonComponent.new)
      end

      def translated_welcome_text
        translated_attribute(settings.welcome_text)
      end

      def background_image
        images_container.attached_uploader(:background_image).path(variant: :big)
      end
    end
  end
end
