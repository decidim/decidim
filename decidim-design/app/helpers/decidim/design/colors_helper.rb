# frozen_string_literal: true

module Decidim
  module Design
    module ColorsHelper
      def colors_sections
        [
          {
            id: t("decidim.design.helpers.base"),
            contents: [
              {
                type: :table,
                options: { headings: [t("decidim.design.helpers.value"), t("decidim.design.helpers.tailwind"), t("decidim.design.helpers.usage")] },
                items: colors_table(
                  { value: "var(--primary)", name: "primary", usage: t("decidim.design.helpers.usage_base_1") },
                  { value: "var(--secondary)", name: "secondary", usage: t("decidim.design.helpers.usage_base_2") },
                  { value: "var(--tertiary)", name: "tertiary", usage: t("decidim.design.helpers.usage_base_3") }
                )
              }
            ]
          },
          {
            id: t("decidim.design.helpers.state"),
            contents: [
              {
                type: :table,
                options: { headings: [t("decidim.design.helpers.value"), t("decidim.design.helpers.tailwind"), t("decidim.design.helpers.hex_code"),
                                      t("decidim.design.helpers.rgba_code"), t("decidim.design.helpers.usage")] },
                items: colors_table(
                  { value: "#28A745", name: "success", rgba: "rgba(40,167,69,1)", usage: t("decidim.design.helpers.usage_state_1") },
                  { value: "#FFB703", name: "warning", rgba: "rgba(255,183,3,1)", usage: t("decidim.design.helpers.usage_state_2") },
                  { value: "#ED1C24", name: "alert", rgba: "rgba(237,28,36,1)", usage: t("decidim.design.helpers.usage_state_3") }
                )
              }
            ]
          },
          {
            id: t("decidim.design.helpers.main_colors"),
            contents: [
              {
                values: section_subtitle(title: t("decidim.design.helpers.typography_texts"))
              },
              {
                type: :table,
                options: { headings: [t("decidim.design.helpers.value"), t("decidim.design.helpers.tailwind"), t("decidim.design.helpers.hex_code"),
                                      t("decidim.design.helpers.rgba_code"), t("decidim.design.helpers.usage")] },
                items: colors_table(
                  { value: "#020203", name: "black", rgba: "rgba(2,2,3,1)", usage: t("decidim.design.helpers.usage_typography_1") },
                  { value: "#3E4C5C", name: "gray-2", rgba: "rgba(62,76,92,1)", usage: t("decidim.design.helpers.usage_typography_2") },
                  { value: "#FFFFFF", name: "white", rgba: "rgba(255,255,255,1)", usage: t("decidim.design.helpers.usage_typography_3") },
                  { value: "#155ABF", name: "secondary", rgba: "rgba(21,90,191,1)", usage: t("decidim.design.helpers.usage_typography_4") }
                )
              },
              {
                values: section_subtitle(title: t("decidim.design.helpers.background"))
              },
              {
                type: :table,
                options: { headings: [t("decidim.design.helpers.value"), t("decidim.design.helpers.tailwind"), t("decidim.design.helpers.hex_code"),
                                      t("decidim.design.helpers.rgba_code"), t("decidim.design.helpers.usage")] },
                items: colors_table(
                  { value: "#F3F4F7", name: "background", rgba: "rgba(243,244,247,1)", usage: t("decidim.design.helpers.usage_background_1") },
                  { value: "#E4EEFF99", name: "background-4", rgba: "rgba(228,238,255,0.8)", usage: t("decidim.design.helpers.usage_background_2") },
                  { value: "#6B7280CC", name: "gray", rgba: "rgba(107,114,128,0.3)", usage: t("decidim.design.helpers.usage_background_3") },
                  { value: "#E1E5EF", name: "gray-3", rgba: "rgba(225,229,239,1)", usage: t("decidim.design.helpers.usage_background_4") },
                  { value: "#242424", name: "gray-4", rgba: "rgba(36,36,36,1)", usage: t("decidim.design.helpers.usage_background_5") },
                  { value: "#F6F8FA", name: "gray-5", rgba: "rgb(246,248,250,1)", usage: t("decidim.design.helpers.usage_background_6") }
                )
              },
              {
                values: section_subtitle(title: t("decidim.design.helpers.form_elements"))
              },
              {
                type: :table,
                options: { headings: [t("decidim.design.helpers.value"), t("decidim.design.helpers.tailwind"), t("decidim.design.helpers.hex_code"),
                                      t("decidim.design.helpers.rgba_code"), t("decidim.design.helpers.usage")] },
                items: colors_table(
                  { value: "#FAFBFC", name: "background-2", rgba: "rgba(250,251,252,1)", usage: t("decidim.design.helpers.usage_formelements_1") },
                  { value: "#EFEFEF", name: "background-3", rgba: "rgba(239,239,239,1))", usage: t("decidim.design.helpers.usage_formelements_2") }
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
