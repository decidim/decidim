# frozen_string_literal: true

module Decidim
  module Design
    module IconographyHelper
      include Decidim::IconHelper
      include Decidim::SocialShareButtonHelper

      def iconography_sections
        (remix_icons + social_share_icons).sort_by { |section| section[:id] }
      end

      def iconography_table(table_rows)
        options = { class: "mx-auto w-4 h-4 text-gray fill-current flex-none" }
        table_rows.map do |table_cell|
          row = []

          row << icon(table_cell[:icon], **options)
          row << content_tag(:code, table_cell[:icon])
          row << table_cell[:category]
          row << table_cell[:description]

          row
        end
      end

      def remix_icons
        Decidim.icons.categories.map do |category, values|
          {
            id: category,
            contents: [
              {
                type: :table,
                options: { headings: %w(Icon Code Category Description) },
                items: iconography_table(values.sort_by { |v| v[:icon] })
              }
            ]
          }
        end
      end

      def social_share_icons
        [
          {
            id: "social-share",
            contents: [
              {
                type: :table,
                options: { headings: %w(Icon Code Category Description) },
                items: social_share_iconography_table
              }
            ]
          }
        ]
      end

      def social_share_iconography_table
        options = { class: "mx-auto w-4 h-4 text-gray fill-current flex-none" }
        Decidim.social_share_services_registry.manifests.map do |service|
          row = []

          row << render_social_share_icon(service, **options)
          row << content_tag(:code, service.name)
          row << "social-share"
          row << t("decidim.shared.share_modal.share_to", service: service.name)

          row
        end
      end
    end
  end
end
