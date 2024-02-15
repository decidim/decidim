# frozen_string_literal: true

module Decidim
  module Design
    module AnnouncementHelper
      def announcement_sections
        [
          {
            id: "callout_class",
            contents: [
              {
                type: :text,
                values: ["This attribute applies an status to the announcement. By default, it uses secondary color."]
              },
              {
                type: :table,
                options: { headings: ["Announcement", "Callout class"] },
                items: announcement_table(
                  { text: "I am an announcement", callout_class: "success" },
                  { text: "I am an announcement", callout_class: "warning" },
                  { text: "I am an announcement", callout_class: "alert" },
                  { text: "I am an announcement", callout_class: "secondary" },
                  { text: "I am an announcement", callout_class: nil }
                ),
                cell_snippet: {
                  cell: "decidim/announcement",
                  args: ["I am an announcement", { callout_class: "success" }],
                  call_string: [
                    'cell("decidim/announcement", "I am an announcement", callout_class: "success")',
                    'cell("decidim/announcement", "I am an announcement", callout_class: "warning")',
                    'cell("decidim/announcement", "I am an announcement", callout_class: "alert")',
                    'cell("decidim/announcement", "I am an announcement", callout_class: "secondary")',
                    'cell("decidim/announcement", "I am an announcement")'
                  ]
                }
              }
            ]
          },
          {
            id: "plain_text_vs_hash",
            contents: [
              {
                type: :text,
                values: ["You can provide as first argument both a plain text and a hash object"]
              },
              {
                type: :table,
                options: { headings: ["Announcement", "Callout class", "Argument"] },
                items: announcement_table(
                  { text: { title: "This is the title", body: "This is the body" }, callout_class: "success",
                    argument: '{ title: "This is the title", body: "This is the body" }, callout_class: "success"' },
                  { text: { title: "This is the title", body: "This is the body" }, callout_class: "warning",
                    argument: '{ title: "This is the title", body: "This is the body" }, callout_class: "warning"' },
                  { text: { title: "This is the title", body: "This is the body" }, callout_class: "alert",
                    argument: '{ title: "This is the title", body: "This is the body" }, callout_class: "alert"' },
                  { text: { title: "This is the title", body: "This is the body" }, callout_class: "secondary",
                    argument: '{ title: "This is the title", body: "This is the body" }, callout_class: "secondary"' },
                  { text: { title: "This is the title", body: "This is the body" }, callout_class: nil,
                    argument: '{ title: "This is the title", body: "This is the body" }' },
                  { text: "I am just plain text", callout_class: nil, argument: '"I am just plain text"' }
                ),
                cell_snippet: {
                  cell: "decidim/announcement",
                  args: [{ title: "This is the title", body: "This is the body" }, { callout_class: "success" }],
                  call_string: [
                    'cell("decidim/announcement", { title: "This is the title", body: "This is the body" }, callout_class: "success")',
                    'cell("decidim/announcement", { title: "This is the title", body: "This is the body" }, callout_class: "warning")',
                    'cell("decidim/announcement", { title: "This is the title", body: "This is the body" }, callout_class: "alert")',
                    'cell("decidim/announcement", { title: "This is the title", body: "This is the body" }, callout_class: "secondary")',
                    'cell("decidim/announcement", { title: "This is the title", body: "This is the body" })',
                    'cell("decidim/announcement", "I am just plain text")'
                  ]
                }
              }
            ]
          }
        ]
      end

      def announcement_table(*table_rows, **_opts)
        table_rows.each_with_index.map do |table_cell, _ix|
          row = []
          row << { method: :cell, args: ["decidim/announcement", table_cell[:text], { callout_class: table_cell[:callout_class] }] }
          row << table_cell[:callout_class]
          row << table_cell[:argument] if table_cell[:argument].present?
          row
        end
      end
    end
  end
end
