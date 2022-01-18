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
      return scopes_selector if name.to_s == "scope_id"

      case type
      when :date, :datetime, :time, :"decidim/attributes/localized_date"
        date_field name
      else
        text_field name
      end
    end

    def scopes_selector
      return if object.user.blank?

      collection_select :scope_id, object.user.organization.scopes, :id, ->(scope) { translated_attribute(scope.name) }
    end

    def find_input_type(name)
      value_type = object.class.attribute_types[name]

      raise "Could not find attribute #{name} in #{object.class.name}" unless value_type

      value_type.type
    end

    def public_attributes
      form_attributes.inject({}) do |all, (name, value_type)|
        all.update(name => value_type.type)
      end
    end

    def form_attributes
      object.class.attribute_types.select do |key, _|
        object.form_attributes.include?(key) || object.form_attributes.include?(key.to_sym)
      end
    end
  end
end
