# frozen_string_literal: true

module Decidim
  module Design
    module IconographyHelper
      include Decidim::IconHelper

      def iconography_sections
        Decidim.icons.categories.sort.map do |category, values|
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

      def iconography_table(table_rows)
        table_rows.map do |table_cell|
          row = []

          row << icon(table_cell[:icon], class: "mx-auto w-4 h-4 text-gray fill-current flex-none")
          row << content_tag(:code, table_cell[:icon])
          row << table_cell[:category]
          row << table_cell[:description]

          row
        end
      end
    end
  end
end
