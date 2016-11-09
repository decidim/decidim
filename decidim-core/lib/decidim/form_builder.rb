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
      field_label = label(name, options[:label] || label_for(name))
      tabs_panels = "".html_safe
      if options[:label] != false
        tabs_panels = content_tag(:ul, class: "tabs", id: "#{name}-tabs", data: { tabs: true }) do
          locales.each_with_index.inject("".html_safe) do |string, (locale, index)|
            string + content_tag(:li, class: tab_element_class_for("title", index)) do
              content_tag(:a, I18n.t(locale, scope: "locales"), href: "##{name}-panel-#{index}")
            end
          end
        end
      end

      tabs_content = content_tag(:div, class: "tabs-content", data: { tabs_content: "#{name}-tabs" }) do
        locales.each_with_index.inject("".html_safe) do |string, (locale, index)|
          string + content_tag(:div, class: tab_element_class_for("panel", index), id: "#{name}-panel-#{index}") do
            send(type, "#{name}_#{locale.to_s.gsub("-", "__")}", options.merge(label: false))
          end
        end
      end

      safe_join [field_label, tabs_panels, tabs_content]
    end

    private

    def tab_element_class_for(type, index)
      element_class = "tabs-#{type}"
      element_class += " is-active" if index.zero?
      element_class
    end

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
