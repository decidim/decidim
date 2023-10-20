# frozen_string_literal: true

module Decidim
  module Design
    module ButtonsHelper
      def buttons_sections
        [
          {
            id: "sizes",
            contents: [
              buttons_table_content(
                { button_classes: "button button__primary button__xs" },
                { button_classes: "button button__primary button__sm" },
                { button_classes: "button button__primary button__lg" },
                { button_classes: "button button__primary button__xl" }
              )
            ]
          },
          {
            id: "colors",
            contents: [
              buttons_table_content(
                { button_classes: "button button__lg button__primary" },
                { button_classes: "button button__lg button__secondary" },
                { button_classes: "button button__lg button__tertiary" }
              )
            ]
          },
          {
            id: "transparent",
            contents: [
              buttons_table_content(
                { button_classes: "button button__lg button__transparent-primary" },
                { button_classes: "button button__lg button__transparent-secondary" },
                { button_classes: "button button__lg button__transparent-tertiary" }
              ),
              {
                type: :text,
                class: "my-4 text-gray-2",
                values: ["In case of a darker background:"]
              },
              buttons_table_content(
                { button_classes: "button button__lg button__transparent" },
                background: true
              )
            ]
          },
          {
            id: "text",
            contents: [
              buttons_table_content(
                { button_classes: "button button__lg button__text" },
                { button_classes: "button button__lg button__text-primary" },
                { button_classes: "button button__lg button__text-secondary" },
                { button_classes: "button button__lg button__text-tertiary" }
              )
            ]
          },
          {
            id: "icons",
            contents: [
              buttons_table_content(
                { button_classes: "button button__lg button__secondary", icon: "question-line" },
                { button_classes: "button button__lg button__transparent-secondary", icon: "question-line" }
              )
            ]
          },
          {
            id: "disabled",
            contents: [
              buttons_table_content(
                {
                  button_classes: "button button__lg button__secondary",
                  html_options: { disabled: true },
                  description: "<code>disabled</code> data-attribute present".html_safe
                }
              )
            ]
          }
        ]
      end

      def button_row(button_args)
        [
          { method: :cell, args: ["decidim/button", button_args.slice(:icon).merge(text: "Send"), button_args] },
          button_args[:description] || button_args[:button_classes]
        ]
      end

      def background_button_row(button_args)
        [
          content_tag(:div, cell("decidim/button", button_args.slice(:icon_name).merge(text: "Send"), button_args), class: "bg-primary p-4 rounded"),
          button_args[:description] || button_args[:button_classes]
        ]
      end

      def buttons_table_content(*buttons_args, **opts)
        {
          type: :partial,
          template: "decidim/design/shared/table",
          locals: { headings: %w(Button Classes), items: buttons_args.map { |button_args| opts[:background] ? background_button_row(button_args) : button_row(button_args) } }
        }
      end
    end
  end
end
