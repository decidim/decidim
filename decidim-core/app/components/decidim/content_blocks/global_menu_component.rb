# frozen_string_literal: true

module Decidim
  module ContentBlocks
    class GlobalMenuComponent < ContentBlockComponent
      include Decidim::MenuHelper

      private

      delegate :decidim_participatory_processes, to: :helpers
      def menu_items
        @menu_items ||= home_content_block_menu.items
      end

      def method_missing(method_name, *_args)
        return super if (engine = engine(method_name)).blank?

        engine.routes.url_helpers
      end

      def respond_to_missing?(method_name, include_private = false)
        method_name.starts_with?("decidim_") || super
      end

      def engine(method_name)
        return if (manifest = Decidim.find_participatory_space_manifest(method_name.to_s.gsub(/\Adecidim_/, ""))).blank?

        manifest.context(:public).engine
      end
    end
  end
end
