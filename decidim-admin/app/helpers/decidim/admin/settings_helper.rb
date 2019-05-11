# frozen_string_literal: true

module Decidim
  module Admin
    # This class contains helpers needed in order for component settings to
    # properly render.
    module SettingsHelper
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
      # attribute - The Settings::Attribute instance with the
      #             description of the attribute.
      # name      - The name of the field.
      # options   - Extra options to be passed to the field helper.
      #
      # Returns a rendered form field.
      def settings_attribute_input(form, attribute, name, options = {})
        if attribute.translated?
          form.send(:translated, form_method_for_attribute(attribute), name, options.merge(tabs_id: "#{options[:tabs_prefix]}-#{name}-tabs"))
        else
          form.send(form_method_for_attribute(attribute), name, options.merge(extra_options_for(name)))
        end
      end

      private

      def form_method_for_attribute(attribute)
        return :editor if attribute.type.to_sym == :text && attribute.editor?
        TYPES[attribute.type.to_sym]
      end

      # Disables :participatory_texts_enabled checkbox if the Proposals component
      # has existing proposals and stores the help text that will be added in a
      # new div via JavaScript in "decidim/admin/form".
      #
      # field_name - The name of the field to disable.
      #
      # Returns an empty Hash or a Hash with extra HTML options.
      def extra_options_for(field_name)
        return {} unless field_name == :participatory_texts_enabled
        return {} unless Decidim::Proposals::Proposal.where(decidim_component_id: params[:id]).any?

        {
          class: "participatory_texts_disabled",
          disabled: true,
          data: { text: t("decidim.admin.components.form.participatory_texts_enabled_help") }
        }
      end
    end
  end
end
