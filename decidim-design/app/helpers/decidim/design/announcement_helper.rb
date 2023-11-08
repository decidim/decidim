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
                  { text: "I am an announcement", callout_class: nil },
                  { text: "I am an announcement", callout_class: "alert" },
                  { text: "I am an announcement", callout_class: "warning" },
                  { text: "I am an announcement", callout_class: "success" }
                ),
                cell_snippet: {
                  cell: "decidim/announcement",
                  args: ["I am an annoucement"]
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
                options: { headings: %w(Announcement Argument) },
                items: announcement_table(
                  { text: "I am just plain text", argument: '"I am just plain text"' },
                  { text: { title: "This is the title", body: "This is the body" }, argument: '{ title: "This is the title", body: "This is the body" }' }
                ),
                cell_snippet: {
                  cell: "decidim/announcement",
                  args: [{ title: "This is the title", body: "This is the body" }]
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
          row << table_cell[:callout_class] if table_cell[:callout_class].present?
          row << table_cell[:argument] if table_cell[:argument].present?
          row
        end
      end
    end
  end
end
