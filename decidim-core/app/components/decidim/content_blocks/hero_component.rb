# frozen_string_literal: true

module Decidim
  module ContentBlocks
    class HeroComponent < Decidim::BaseComponent
      def initialize(content_block)
        @model = content_block
      end

      class CtaButtonComponent < Decidim::BaseComponent
        include Decidim::CtaButtonHelper

        # Needed so that the `CtaButtonHelper` can work.
        def decidim_participatory_processes
          Decidim::ParticipatoryProcesses::Engine.routes.url_helpers
        end
      end

      private

      attr_reader :model

      def cta_button
        render(CtaButtonComponent.new)
      end

      def translated_welcome_text
        translated_attribute(model.settings.welcome_text)
      end

      def background_image
        model.images_container.attached_uploader(:background_image).path(variant: :big)
      end
    end
  end
end
