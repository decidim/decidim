# frozen_string_literal: true
require "foundation_rails_helper/form_builder"

module Decidim
  # This custom FormBuilder adds fields needed to deal with translatable fields,
  # following the conventions set on `Decidim::TranslatableAttributes`.
  class FormBuilder < FoundationRailsHelper::FormBuilder
    # Public: Generates an form field for each locale.
    #
    # type - The form field's type, like `text_area` or `text_input`
    # name - The name of the field
    # options - The set of options to send to the field
    #
    # Renders form fields for each locale.
    def translated(type, name, options = {})
      locales.map do |locale|
        label = options[:label] || label_for(name)
        language = locale

        send(type, "#{name}_#{locale.to_s.gsub("-", "__")}", options.merge(label: "#{label} (#{language})"))
      end.join.html_safe
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
