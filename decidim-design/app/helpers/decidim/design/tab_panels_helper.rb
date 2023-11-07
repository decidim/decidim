# frozen_string_literal: true

module Decidim
  module Design
    module TabPanelsHelper
      def tab_panels_sections
        [
          {
            id: "usage",
            contents: [
              {
                type: :text,
                values: [
                  "This component receives an array of hashes, and rearrange the output of each item into a tab-panel structure",
                  "Available properties for each panel:",
                  "<i>enabled</i>: Boolean. conditionally render the tab",
                  "<i>id</i>: String. unique id",
                  "<i>text</i>: String. tab title",
                  "<i>icon</i>: String. remixicon key",
                  "<i>method</i>: Symbol. any function rails understands",
                  "<i>args</i>: Array. arguments for the previous method",
                ]
              },
              {
                type: :table,
                options: { headings: ["Display", "Values"], style: "--cell-width: 50%;" },
                items: tab_panels_table(
                  { values: tab_panels_items },
                  { values: tab_panels_items_2 },
                ),
                cell_snippet: {
                  cell: "decidim/tab_panels",
                  args: [tab_panels_items]
                }
              }
            ]
          }
        ]
      end

      def tab_panels_table(*table_rows, **_opts)
        table_rows.each_with_index.map do |table_cell, _ix|
          row = []
          row << { method: :cell, args: ["decidim/tab_panels", table_cell[:values]] }
          row << content_tag(:pre, content_tag(:code, JSON.pretty_generate(table_cell[:values])), class: "text-left")
          row
        end
      end

      def tab_panels_items
        [
          {
            enabled: true,
            id: "button",
            text: "Button",
            icon: resource_type_icon_key("images"),
            method: :cell,
            args: ["decidim/button", { text: "Send" }]
          },
          {
            enabled: true,
            id: "announce",
            text: "Announcement",
            icon: resource_type_icon_key("documents"),
            method: :cell,
            args: ["decidim/announcement", "I am an annoucement"]
          },
        ]
      end

      def tab_panels_items_2
        [
          {
            enabled: true,
            id: "icon",
            text: "Icon",
            method: :icon,
            args: ["question-line", class: "w-4 h-4"]
          },
          {
            enabled: true,
            id: "text",
            text: "Plain",
            method: :content_tag,
            args: ["p", "plain text", class: "text-left"]
          },
        ]
      end
    end
  end
end
