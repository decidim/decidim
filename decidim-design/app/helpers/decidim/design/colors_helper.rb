# frozen_string_literal: true

module Decidim
  module Design
    module ColorsHelper
      def colors_sections
        [
          {
            id: "base",
            contents: [
              {
                type: :table,
                options: { headings: ["Value", "Tailwind name", "Usage"] },
                items: colors_table(
                  { value: "var(--primary)", name: "primary", usage: "Main nav component background\nNav menus in homepage and space home" },
                  { value: "var(--secondary)", name: "secondary", usage: "Main color for links and buttons" },
                  { value: "var(--tertiary)", name: "tertiary", usage: "Graphic ornaments and accent color\nCards and list items hover state border" }
                )
              }
            ]
          },
          {
            id: "state",
            contents: [
              {
                type: :table,
                options: { headings: ["Value", "Tailwind name", "Hex code", "RGBA code", "Usage"] },
                items: colors_table(
                  { value: "#28A745", name: "success", rgba: "rgba(40,167,69,1)", usage: "Success notice border\nAlert notice icon fill\nButton background on success message" },
                  { value: "#FFB703", name: "warning", rgba: "rgba(255,183,3,1)", usage: "Warning notice border" },
                  { value: "#ED1C24", name: "alert", rgba: "rgba(237,28,36,1)", usage: "Alert notice border\nAlert notice icon fill" }
                )
              }
            ]
          },
          {
            id: "main_colors",
            contents: [
              {
                values: section_subtitle(title: "Typography and texts")
              },
              {
                type: :table,
                options: { headings: ["Value", "Tailwind name", "Hex code", "RGBA code", "Usage"] },
                items: colors_table(
                  { value: "#020203", name: "black", rgba: "rgba(2,2,3,1)", usage: "Headings and section titles" },
                  { value: "#3E4C5C", name: "gray-2", rgba: "rgba(62,76,92,1)", usage: "Inline text" },
                  { value: "#FFFFFF", name: "white", rgba: "rgba(255,255,255,1)", usage: "Text over dark background" },
                  { value: "#155ABF", name: "secondary", rgba: "rgba(21,90,191,1)", usage: "Links and buttons" }
                )
              },
              {
                values: section_subtitle(title: "Background and borders")
              },
              {
                type: :table,
                options: { headings: ["Value", "Tailwind name", "Hex code", "RGBA code", "Usage"] },
                items: colors_table(
                  { value: "#F3F4F7", name: "background", rgba: "rgba(243,244,247,1)", usage: "Aside background" },
                  { value: "#E4EEFF99", name: "background-4", rgba: "rgba(228,238,255,0.8)", usage: "Selected sidebar filter background" },
                  { value: "#6B7280CC", name: "gray", rgba: "rgba(107,114,128,0.3)", usage: "Default icon color" },
                  { value: "#E1E5EF", name: "gray-3", rgba: "rgba(225,229,239,1)", usage: "Lines and separators" },
                  { value: "#242424", name: "gray-4", rgba: "rgba(36,36,36,1)", usage: "Footer background" },
                  { value: "#F6F8FA", name: "gray-5", rgba: "rgb(246,248,250,1)", usage: "Admin layout background" }
                )
              },
              {
                values: section_subtitle(title: "Form elements")
              },
              {
                type: :table,
                options: { headings: ["Value", "Tailwind name", "Hex code", "RGBA code", "Usage"] },
                items: colors_table(
                  { value: "#FAFBFC", name: "background-2", rgba: "rgba(250,251,252,1)", usage: "Input elements default background" },
                  { value: "#EFEFEF", name: "background-3", rgba: "rgba(239,239,239,1))", usage: "Input elements disabled state background" }
                )
              }
            ]
          }
        ]
      end

      def colors_table(*table_rows, **_opts)
        table_rows.map do |table_cell|
          row = []
          row << content_tag(:div, nil, class: "w-8 h-8 rounded shadow", style: "background-color: #{table_cell[:value]};")
          row << table_cell[:name]
          row << table_cell[:value] if table_cell[:rgba].present?
          row << table_cell[:rgba] if table_cell[:rgba].present?
          row << table_cell[:usage]
          row
        end
      end
    end
  end
end
