# frozen_string_literal: true

module Decidim
  module Design
    module AnnouncementHelper
      def announcement_sections
        [
          {
            title: t("decidim.design.helpers.callout_class"),
            contents: [
              {
                type: :text,
                values: [t("decidim.design.helpers.callout_description")]
              },
              {
                type: :table,
                options: { headings: [t("decidim.design.components.announcement.title"), t("decidim.design.helpers.callout_class")] },
                items: announcement_table(
                  { text: t("decidim.design.components.announcement.iam_an_announcement"), callout_class: "success" },
                  { text: t("decidim.design.components.announcement.iam_an_announcement"), callout_class: "warning" },
                  { text: t("decidim.design.components.announcement.iam_an_announcement"), callout_class: "alert" },
                  { text: t("decidim.design.components.announcement.iam_an_announcement"), callout_class: "secondary" },
                  { text: t("decidim.design.components.announcement.iam_an_announcement"), callout_class: nil }
                ),
                cell_snippet: {
                  cell: "decidim/announcement",
                  args: [t("decidim.design.components.announcement.iam_an_announcement"), { callout_class: "success" }],
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
            title: t("decidim.design.helpers.plain_text_vs_hash"),
            contents: [
              {
                type: :text,
                values: [t("decidim.design.helpers.plain_text_description")]
              },
              {
                type: :table,
                options: { headings: [t("decidim.design.components.announcement.title"), t("decidim.design.helpers.callout_class"), t("decidim.design.helpers.argument")] },
                items: announcement_table(
                  { text: { title: t("decidim.design.components.announcement.this_is_the_title"), body: t("decidim.design.components.announcement.this_is_the_body") },
                    callout_class: "success",
                    argument: '{ title: "This is the title", body: "This is the body" }, callout_class: "success"' },
                  { text: { title: t("decidim.design.components.announcement.this_is_the_title"), body: t("decidim.design.components.announcement.this_is_the_body") },
                    callout_class: "warning",
                    argument: '{ title: "This is the title", body: "This is the body" }, callout_class: "warning"' },
                  { text: { title: t("decidim.design.components.announcement.this_is_the_title"), body: t("decidim.design.components.announcement.this_is_the_body") },
                    callout_class: "alert",
                    argument: '{ title: "This is the title", body: "This is the body" }, callout_class: "alert"' },
                  { text: { title: t("decidim.design.components.announcement.this_is_the_title"), body: t("decidim.design.components.announcement.this_is_the_body") },
                    callout_class: "secondary",
                    argument: '{ title: "This is the title", body: "This is the body" }, callout_class: "secondary"' },
                  { text: { title: t("decidim.design.components.announcement.this_is_the_title"), body: t("decidim.design.components.announcement.this_is_the_body") },
                    callout_class: nil,
                    argument: '{ title: "This is the title", body: "This is the body" }' },
                  { text: t("decidim.design.helpers.plain_text"), callout_class: nil, argument: '"I am just plain text"' }
                ),
                cell_snippet: {
                  cell: "decidim/announcement",
                  args: [{ title: t("decidim.design.components.announcement.this_is_the_title"), body: t("decidim.design.components.announcement.this_is_the_body") },
                         { callout_class: "success" }],
                  call_string: [
                    %{cell("decidim/announcement", { title: "This is the title", body: "This is the body" }, callout_class: "success")},
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
