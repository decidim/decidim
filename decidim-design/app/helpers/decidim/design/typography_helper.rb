# frozen_string_literal: true

module Decidim
  module Design
    module TypographyHelper
      def typography_sections
        [
          {
            id: "typefaces",
            contents: [
              {
                type: :text,
                values: [
                  "Decidim uses Source Sans Pro as primary typeface. This typeface supports 310 languages",
                  "This fonts are licensed under the Open Font License"
                ]
              },
              {
                type: :table,
                options: { headings: %w(Example) },
                items: typography_table(
                  { type: "typefaces", example: "Source Sans Pro Bold", class: "font-bold" },
                  { type: "typefaces", example: "Source Sans Pro Semibold", class: "font-semibold" },
                  { type: "typefaces", example: "Source Sans Pro Regulars", class: "font-normal" }
                )
              }
            ]
          },
          {
            id: "headings",
            contents: [
              {
                type: :table,
                options: { headings: ["Level", "Semibold 600", "Bold 700", "Size"] },
                items: typography_table(
                  { type: "headings", level: "Hero H1", text: "Hero heading", size: "text-5xl" },
                  { type: "headings", level: "H1", text: "Heading H1", size: "text-4xl" },
                  { type: "headings", level: "H2", text: "Heading H2", size: "text-3xl" },
                  { type: "headings", level: "H3", text: "Heading H3", size: "text-2xl" },
                  { type: "headings", level: "H4", text: "Heading H4", size: "text-xl" },
                  { type: "headings", level: "H5", text: "Heading H5", size: "text-lg" },
                  { type: "headings", level: "H6", text: "Heading H6", size: "text-md" }
                )
              }
            ]
          },
          {
            id: "content",
            contents: [
              {
                type: :table,
                options: { headings: ["Regular 400", "Semibold 600", "Bold 700", "Size"] },
                items: typography_table(
                  { type: "content", text: "Sample content", size: "text-xl" },
                  { type: "content", text: "Sample content", size: "text-lg" },
                  { type: "content", text: "Sample content", size: "text-md" },
                  { type: "content", text: "Sample content", size: "text-sm" },
                  { type: "content", text: "Sample content", size: "text-xs" }
                )
              }
            ]
          },
          {
            id: "readability",
            contents: [
              {
                type: :table,
                options: { headings: ["Size", "Layout cols", "~ Characters per line"] },
                items: typography_table(
                  { type: "readability", size: "text-xl", layout: 6, chars: 81 },
                  { type: "readability", size: "text-lg", layout: 6, chars: 90 },
                  { type: "readability", size: "text-md", layout: 5, chars: 84 },
                  { type: "readability", size: "text-sm", layout: 4, chars: 76 }
                )
              }
            ]
          }
        ]
      end

      def typography_table(*table_rows, **_opts)
        table_rows.each_with_index.map do |table_cell, ix|
          row = []

          row << content_tag(:span, table_cell[:example], class: "text-lg #{table_cell[:class]}") if table_cell[:type] == "typefaces"

          if table_cell[:type] == "headings"
            row << table_cell[:level]
            row << content_tag(:span, ix.positive? ? table_cell[:text] : "", class: "font-semibold #{table_cell[:size]}")
            row << content_tag(:span, table_cell[:text], class: "font-bold #{table_cell[:size]}")
            row << content_tag(:span, table_cell[:size], class: "text-secondary underline text-center")
          end

          if table_cell[:type] == "content"
            row << content_tag(:span, table_cell[:text], class: "font-normal #{table_cell[:size]}")
            row << content_tag(:span, table_cell[:text], class: "font-semibold  #{table_cell[:size]}")
            row << content_tag(:span, table_cell[:text], class: "font-bold  #{table_cell[:size]}")
            row << content_tag(:span, table_cell[:size], class: "text-secondary underline text-center")
          end

          if table_cell[:type] == "readability"
            row << content_tag(:span, table_cell[:size], class: "text-secondary underline")
            row << table_cell[:layout].to_s
            row << table_cell[:chars].to_s
          end

          row
        end
      end
    end
  end
end
