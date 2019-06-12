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

      # Returns an empty Hash or a Hash with extra HTML options.
      def extra_options_for(field_name)
        case field_name
        when :participatory_texts_enabled
          participatory_texts_extra_options
        when :amendments_enabled
          amendments_extra_options(field_name, :global)
        when :amendment_creation_enabled,
             :amendment_reaction_enabled,
             :amendment_promotion_enabled
          amendments_extra_options(field_name, :step)
        else
          {}
        end
      end

      # Marks :participatory_texts_enabled checkbox with a unique class if
      # the Proposals component has existing proposals, and stores the help text
      # that will be added in a new div via JavaScript in "decidim/admin/form".
      def participatory_texts_extra_options
        return {} unless Decidim::Proposals::Proposal.where(component: @component).any?

        {
          class: "participatory_texts_disabled field_has_help_text",
          data: { text: t("decidim.admin.components.form.participatory_texts_enabled_help") }
        }
      end

      def amendments_extra_options(field_name, settings_scope)
        {
          class: "field_has_help_text",
          data: { text: t("#{settings_scope}.#{field_name}_help", scope: "decidim.components.proposals.settings") }
        }
      end
    end
  end
end
