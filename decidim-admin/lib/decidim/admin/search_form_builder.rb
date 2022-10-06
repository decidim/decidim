# frozen_string_literal: true

module Decidim
  module Admin
    # This custom FormBuilder extends the Admin::FormBuilder with the needed
    # functionality for the Ransack search forms. Adapts functionality from
    # Ransack::Helpers::FormBuilder to the FoundationRailsHelper::FormBuilder
    # that we use as the form builder in the admin views.
    class SearchFormBuilder < Decidim::Admin::FormBuilder
      private

      # Translates the form labels using the translation method available for
      # the Ransack::Search objects.
      #
      # @see Ransack::Helpers::FormBuilder#default_label_text
      # @see Ransack::Nodes::Node#translate
      # @see Ransack::Nodes::Grouping#translate
      def default_label_text(object, attribute, i18n_options = {})
        if object.respond_to?(:translate)
          return object.translate(
            attribute,
            i18n_options.reverse_merge(include_associations: true)
          )
        end

        super(object, attribute)
      end

      # Passes the `:i18n` options for the default_label_text method from the
      # options passed for the custom_label method.
      #
      # @see FoundationRailsHelper::FormBuilder#custom_label
      def custom_label(attribute, text, options)
        text = default_label_text(object, attribute, options.delete(:i18n) || {}) if text.nil? || text == true
        super(attribute, text, options)
      end
    end
  end
end
