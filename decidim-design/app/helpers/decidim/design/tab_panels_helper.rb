# frozen_string_literal: true

module Decidim
  module Design
    module TabPanelsHelper
      def tab_panels_sections
        [
          {
            id: "context",
            contents: [
              {
                type: :text,
                values: [
                  "This tab-panel component gathers all the related contents or another resources of the main element displayed,
                    in order to save vertical space. Clicking on the tab will activate the created panel to show the content.",
                  "Mainly is used within the <i>layout_item</i> or the <i>layout_center</i>, after the main content of the resource."
                ]
              }
            ]
          },
          {
            id: "usage",
            contents: [
              {
                type: :text,
                values: [
                  "This component receives an array of hashes, and rearrange the output of each item into a tab-panel structure. Available properties for each panel:",
                  "<strong>enabled</strong>: <i>Boolean</i>. Conditionally render the tab",
                  "<strong>id</strong>: <i>String</i>. Unique id",
                  "<strong>text</strong>: <i>String</i>. Tab title",
                  "<strong>icon</strong>: <i>String</i>. Remixicon key",
                  "<strong>method</strong>: <i>Symbol</i>. Any function rails understands",
                  "<strong>args</strong>: <i>Array</i>. Arguments for the previous method"
                ]
              },
              {
                type: :table,
                options: { headings: %w(Display Values), style: "--cell-width: 50%;" },
                items: tab_panels_table(
                  { values: tab_panels_items },
                  { values: tab_panels_items_alt }
                ),
                cell_snippet: {
                  cell: "decidim/tab_panels",
                  args: [tab_panels_items],
                  call_string: [<<-TEXT1, <<-TEXT2]
  cell(
      "decidim/tab_panels",
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
          args: ["decidim/announcement", "I am an announcement"]
        }
      ]
    )
                  TEXT1
  cell(
      "decidim/tab_panels",
      [
        {
          enabled: true,
          id: "icon",
          text: "Icon",
          method: :icon,
          args: ["question-line", { class: "w-4 h-4" }]
        },
        {
          enabled: true,
          id: "text",
          text: "Plain",
          method: :content_tag,
          args: ["p", "plain text", { class: "text-left" }]
        }
      ]
    )
                  TEXT2
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
            args: ["decidim/announcement", "I am an announcement"]
          }
        ]
      end

      def tab_panels_items_alt
        [
          {
            enabled: true,
            id: "icon",
            text: "Icon",
            method: :icon,
            args: ["question-line", { class: "w-4 h-4" }]
          },
          {
            enabled: true,
            id: "text",
            text: "Plain",
            method: :content_tag,
            args: ["p", "plain text", { class: "text-left" }]
          }
        ]
      end
    end
  end
end
