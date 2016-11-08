# frozen_string_literal: true
require "foundation_rails_helper/form_builder"

module Decidim
  # This custom FormBuilder adds fields needed to deal with translatable fields,
  # following the conventions set on `Decidim::TranslatableAttributes`.
  class FormBuilder < FoundationRailsHelper::FormBuilder
    include ActionView::Context

    # Public: Generates an form field for each locale.
    #
    # type - The form field's type, like `text_area` or `text_input`
    # name - The name of the field
    # options - The set of options to send to the field
    #
    # Renders form fields for each locale.
    def translated(type, name, options = {})
      tabs_panels = "".html_safe
      if options[:label] != false
        tabs_panels = content_tag(:ul, class: "tabs", id: "#{name}-tabs", data: { tabs: true }) do
          content_tag(:p, "HEY")
          locales.each_with_index.inject("".html_safe) do |string, (locale, index)|
            element_class = "tabs-title"
            element_class += " is-active" if index.zero?
            string + content_tag(:li, class: element_class) do
              label = options[:label] || label_for(name)
              content_tag(:a, "#{label} (#{locale})", href: "##{name}-panel-#{index}")
            end
          end
        end
      end

      tabs_contents = content_tag(:div, class: "tabs-content", data: { tabs_content: "#{name}-tabs" }) do
        locales.each_with_index.inject("".html_safe) do |string, (locale, index)|
          element_class = "tabs-panel"
          element_class += " is-active" if index.zero?

          string + content_tag(:div, class: element_class, id: "#{name}-panel-#{index}") do
            send(type, "#{name}_#{locale.to_s.gsub("-", "__")}", options.merge(label: false))
          end
        end
      end

      [tabs_panels, tabs_contents].join.html_safe
    end

    private

    def locales
      I18n.available_locales
    end

    def label_for(attribute)
      if object.class.respond_to?(:human_attribute_name)
        object.class.human_attribute_name(attribute)
      else
        attribute.to_s.humanize
      end
    end
  end
end
