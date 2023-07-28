# frozen_string_literal: true

module Decidim
  module ContentBlocks
    class ParticipatorySpaceSocialNetworksCell < BaseCell
      def show
        return if social_handler_items.blank?

        render
      end

      def social_handler_items
        Decidim::Organization::SOCIAL_HANDLERS.filter_map do |handler|
          if (handler_name = resource.try("#{handler}_handler")).present?
            {
              icon: "#{handler}-line",
              value: link_to(
                handler.capitalize,
                "https://#{handler}.com/#{handler_name}",
                target: "_blank",
                class: "text-secondary underline",
                title: "#{t("show.social_networks_title", scope: "decidim.#{resource.manifest.name}")} #{handler.capitalize}",
                rel: "noopener"
              )
            }
          end
        end
      end
    end
  end
end
