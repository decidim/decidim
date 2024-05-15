# frozen_string_literal: true

module Decidim
  module Design
    module TabPanelsHelper
      def tab_panels_sections
        [
          {
            id: "context",
            title: t("decidim.design.helpers.context"),
            contents: [
              {
                type: :text,
                values: [
                  t("decidim.design.helpers.tab_panels_context_description"),
                  t("decidim.design.helpers.tab_panels_context_description_html")
                ]
              }
            ]
          },
          {
            id: "usage",
            title: t("decidim.design.helpers.usage"),
            contents: [
              {
                type: :text,
                values: [
                  t("decidim.design.helpers.tab_panels_usage_description"),
                  t("decidim.design.helpers.tab_panels_usage_description_html"),
                  t("decidim.design.helpers.tab_panels_usage_description_id_html"),
                  t("decidim.design.helpers.tab_panels_usage_description_tab_html"),
                  t("decidim.design.helpers.tab_panels_usage_description_remixicon_html"),
                  t("decidim.design.helpers.tab_panels_usage_description_rails_html"),
                  t("decidim.design.helpers.tab_panels_usage_description_arguments_html")
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
            args: ["decidim/button", { text: t("decidim.design.helpers.send") }]
          },
          {
            enabled: true,
            id: "announce",
            text: "Announcement",
            icon: resource_type_icon_key("documents"),
            method: :cell,
            args: ["decidim/announcement", t("decidim.design.components.announcement.iam_an_announcement")]
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
