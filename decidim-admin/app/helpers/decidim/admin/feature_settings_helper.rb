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
      }

      def settings_attribute_input(form, attribute, name, options = {})
        form.send(TYPES[attribute.type.to_sym], name, options)
      end
    end
  end
end
