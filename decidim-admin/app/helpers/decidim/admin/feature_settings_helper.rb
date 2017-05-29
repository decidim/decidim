# frozen_string_literal: true

module Decidim
  module Admin
    # This class contains helpers needed in order for feature settings to
    # properly render.
    module FeatureSettingsHelper
      TYPES = {
        boolean: :check_box,
        integer: :number_field,
        string: :text_field,
        text: :text_area
      }.freeze

      # Public: Renders a form field that matches a settings attribute's
      # type.
      #
      # form      - The form in which to render the field.
      # attribute - The FeatureSettings::Attribute instance with the
      #             description of the attribute.
      # name      - The name of the field.
      # options   - Extra options to be passed to the field helper.
      #
      # Returns a rendered form field.
      def settings_attribute_input(form, attribute, name, options = {})
        form.send(TYPES[attribute.type.to_sym], name, options)
      end
    end
  end
end
