# frozen_string_literal: true

module Decidim
  module Design
    module ButtonsHelper
      def buttons_sections
        [
          {
            id: "sizes",
            contents: [
              {
                type: :table,
                options: buttons_table_options,
                items: buttons_table_items_from_args(
                  { button_classes: "button button__primary button__xs" },
                  { button_classes: "button button__primary button__sm" },
                  { button_classes: "button button__primary button__lg" },
                  { button_classes: "button button__primary button__xl" }
                ),
                cell_snippet: {
                  cell: "decidim/button",
                  args: [{ text: "Send" }, { button_classes: "button button__primary button__xs" }],
                  call_string: [
                    'cell("decidim/button", { text: "Send" }, { button_classes: "button button__primary button__xs" })',
                    'cell("decidim/button", { text: "Send" }, { button_classes: "button button__primary button__sm" })',
                    'cell("decidim/button", { text: "Send" }, { button_classes: "button button__primary button__lg" })',
                    'cell("decidim/button", { text: "Send" }, { button_classes: "button button__primary button__xl" })'
                  ]
                }
              }
            ]
          },
          {
            id: "colors",
            contents: [
              {
                type: :table,
                options: buttons_table_options,
                items: buttons_table_items_from_args(
                  { button_classes: "button button__lg button__primary" },
                  { button_classes: "button button__lg button__secondary" },
                  { button_classes: "button button__lg button__tertiary" }
                ),
                cell_snippet: {
                  cell: "decidim/button",
                  args: [{ text: "Send" }, { button_classes: "button button__lg button__primary" }],
                  call_string: [
                    'cell("decidim/button", { text: "Send" }, { button_classes: "button button__lg button__primary" })',
                    'cell("decidim/button", { text: "Send" }, { button_classes: "button button__lg button__secondary" })',
                    'cell("decidim/button", { text: "Send" }, { button_classes: "button button__lg button__tertiary" })'
                  ]
                }
              }
            ]
          },
          {
            id: "transparent",
            contents: [
              {
                type: :table,
                options: buttons_table_options,
                items: buttons_table_items_from_args(
                  { button_classes: "button button__lg button__transparent-primary" },
                  { button_classes: "button button__lg button__transparent-secondary" },
                  { button_classes: "button button__lg button__transparent-tertiary" }
                ),
                cell_snippet: {
                  cell: "decidim/button",
                  args: [{ text: "Send" }, { button_classes: "button button__lg button__transparent-primary" }],
                  call_string: [
                    'cell("decidim/button", { text: "Send" }, { button_classes: "button button__lg button__transparent-primary" })',
                    'cell("decidim/button", { text: "Send" }, { button_classes: "button button__lg button__transparent-secondary" })',
                    'cell("decidim/button", { text: "Send" }, { button_classes: "button button__lg button__transparent-tertiary" })'
                  ]
                }
              },
              {
                type: :text,
                values: ["In case of a darker background:"]
              },
              {
                type: :table,
                options: buttons_table_options,
                items: buttons_table_items_from_args(
                  { button_classes: "button button__lg button__transparent" },
                  background: true
                ),
                cell_snippet: {
                  cell: "decidim/button",
                  args: [{ text: "Send" }, { button_classes: "button button__lg button__transparent" }],
                  call_string: 'cell("decidim/button", { text: "Send" }, { button_classes: "button button__lg button__transparent" })'
                }
              }
            ]
          },
          {
            id: "text",
            contents: [
              {
                type: :table,
                options: buttons_table_options,
                items: buttons_table_items_from_args(
                  { button_classes: "button button__lg button__text" },
                  { button_classes: "button button__lg button__text-primary" },
                  { button_classes: "button button__lg button__text-secondary" },
                  { button_classes: "button button__lg button__text-tertiary" }
                ),
                cell_snippet: {
                  cell: "decidim/button",
                  args: [{ text: "Send" }, { button_classes: "button button__lg button__text" }],
                  call_string: [
                    'cell("decidim/button", { text: "Send" }, { button_classes: "button button__lg button__text" })',
                    'cell("decidim/button", { text: "Send" }, { button_classes: "button button__lg button__text-primary" })',
                    'cell("decidim/button", { text: "Send" }, { button_classes: "button button__lg button__text-secondary" })',
                    'cell("decidim/button", { text: "Send" }, { button_classes: "button button__lg button__text-tertiary" })'
                  ]
                }
              }
            ]
          },
          {
            id: "icons",
            contents: [
              {
                type: :table,
                options: buttons_table_options,
                items: buttons_table_items_from_args(
                  { button_classes: "button button__lg button__secondary", icon: "question-line" },
                  { button_classes: "button button__lg button__transparent-secondary", icon: "question-line" }
                ),
                cell_snippet: {
                  cell: "decidim/button",
                  args: [{ text: "Send", icon: "question-line" }, { button_classes: "button button__lg button__secondary" }],
                  call_string: [
                    'cell("decidim/button", { text: "Send", icon: "question-line" }, { button_classes: "button button__lg button__secondary" })',
                    'cell("decidim/button", { text: "Send", icon: "question-line" }, { button_classes: "button button__lg button__transparent-secondary" })'
                  ]
                }
              }
            ]
          },
          {
            id: "disabled",
            contents: [
              {
                type: :table,
                options: buttons_table_options,
                items: buttons_table_items_from_args(
                  {
                    button_classes: "button button__lg button__secondary",
                    html_options: { disabled: true },
                    description: "<code>disabled</code> data-attribute present".html_safe
                  }
                ),
                cell_snippet: {
                  cell: "decidim/button",
                  args: [
                    { text: "Send" },
                    { button_classes: "button button__lg button__secondary", html_options: { disabled: true } }
                  ],
                  call_string: 'cell("decidim/button", { text: "Send" }, { button_classes: "button button__lg button__secondary", html_options: { disabled: true } })'
                }
              }
            ]
          }
        ]
      end

      def button_row(button_args)
        cell_args = { cell: "decidim/button", args: [button_args.slice(:icon).merge(text: "Send"), button_args] }
        [
          { method: :cell, args: [cell_args[:cell], *cell_args[:args]] },
          button_args[:description] || button_args[:button_classes]
        ]
      end

      def background_button_row(button_args)
        cell_args = { cell: "decidim/button", args: [button_args.slice(:icon).merge(text: "Send"), button_args] }
        [
          content_tag(:div, cell(cell_args[:cell], *cell_args[:args]), class: "bg-primary p-4 rounded"),
          button_args[:description] || button_args[:button_classes]
        ]
      end

      def buttons_table_items_from_args(*buttons_args, **opts)
        buttons_args.map do |button_args|
          opts[:background] ? background_button_row(button_args) : button_row(button_args)
        end
      end

      def buttons_table_options
        @buttons_table_options ||= { headings: %w(Button Classes) }
      end
    end
  end
end
