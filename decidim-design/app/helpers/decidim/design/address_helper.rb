# frozen_string_literal: true

module Decidim
  module Design
    module AddressHelper
      def address_sections
        [
          {
            id: "demo",
            contents: [
              {
                type: :text,
                values: [
                  "Address cell receives a resource, and searches the geolocalizable attributes to render an specific markup.",
                ]
              },
              {
                type: :partial,
                template: "decidim/design/components/address/static-address-person"
              },
              {
                type: :text,
                values: [
                  "Depending of the type of the content, the address could be an online url.
                    For such cases, the displayed information is quite the same but shaped to fit."
                ]
              },
              {
                type: :partial,
                template: "decidim/design/components/address/static-address-online"
              }
            ]
          },
          {
            id: "sourcecode",
            contents: [
              {
                type: :table,
                options: { headings: %w(Cell Code) },
                items: address_table(
                  { name: "Address", url: "https://github.com/decidim/decidim/blob/develop/decidim-core/app/cells/decidim/address_cell.rb" }
                )
              }
            ]
          }
        ]
      end

      def address_table(*table_rows, **_opts)
        table_rows.map do |table_cell|
          row = []
          row << table_cell[:name]
          row << link_to(table_cell[:url].split("/").last, table_cell[:url], target: "_blank", class: "text-secondary underline", rel: "noopener")
          row
        end
      end
    end
  end
end
