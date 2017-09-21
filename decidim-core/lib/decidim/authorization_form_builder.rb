# frozen_string_literal: true

require "decidim/form_builder"

module Decidim
  # A custom form builder to render AuthorizationHandler forms.
  class AuthorizationFormBuilder < Decidim::FormBuilder
    # Renders all form attributes defined by the handler.
    #
    # Returns a String.
    def all_fields
      fields = public_attributes.map do |name, type|
        @template.content_tag(:div, input_field(name, type), class: "field")
      end

      safe_join(fields)
    end

    # Renders a single attribute from the form handlers.
    #
    # name - The String name of the attribute.
    # options - An optional Hash, accepted options are:
    #           :as - A String name with the type the field to render
    #           :input - An optional Hash to pass to the field method.
    #
    # Returns a String.
    def input(name, options = {})
      if options[:as]
        send(options[:as].to_s, name, options[:input] || {})
      else
        type = find_input_type(name.to_s)
        input_field(name, type)
      end
    end

    private

    def input_field(name, type)
      return hidden_field(name) if name.to_s == "handler_name"

      case type.name
      when "Date"
        date_field name
      else
        text_field name
      end
    end

    def find_input_type(name)
      found_attribute = object.class.attribute_set.detect do |attribute|
        attribute.name.to_s == name
      end

      raise "Could not find attribute #{name} in #{object.class.name}" unless found_attribute

      found_attribute.type.primitive
    end

    def public_attributes
      form_attributes.inject({}) do |all, attribute|
        all.update(attribute.name => attribute.type.primitive)
      end
    end

    def form_attributes
      object.class.attribute_set.select do |attribute|
        object.form_attributes.include?(attribute.name)
      end
    end
  end
end
