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
        if name == :amendments_visibility
          amendments_visibility_form_field(form, options)
        elsif attribute.translated?
          form.send(:translated, form_method_for_attribute(attribute), name, options.merge(tabs_id: "#{options[:tabs_prefix]}-#{name}-tabs"))
        else
          form.send(form_method_for_attribute(attribute), name, options.merge(extra_options_for(name)))
        end
      end

      # Returns a translation or nil. If nil, ZURB Foundation won't add the help_text.
      def help_text_for_component_setting(field_name, settings_name, component_name)
        key = "decidim.components.#{component_name}.settings.#{settings_name}.#{field_name}_help"
        return t(key) if I18n.exists?(key)
      end

      private

      # Returns a radio buttons collection input for the component's step setting
      # :amendments_visibility; all wrap in a label tag and with help text.
      def amendments_visibility_form_field(form, options)
        collection = Decidim::Amendment::VisibilityStepSetting.options
        checked = if @component.step_settings.present?
                    step_number = options[:tabs_prefix].split("-")[1] # Gets number in String like "step-N-settings"
                    @component.step_settings[step_number][:amendments_visibility]
                  else
                    @component.current_settings[:amendments_visibility]
                  end

        radio_buttons = form.collection_radio_buttons(:amendments_visibility,
                                                      collection,
                                                      :last,
                                                      :first,
                                                      { checked: checked },
                                                      amendments_extra_options) { |b| b.label { b.radio_button + b.text } }

        html = label_tag(:amendments_visibility) do
          concat options[:label]
          concat tag(:br)
          concat radio_buttons
        end
        html << content_tag(:p, help_text_for_component_setting(:amendments_visibility, :step, :proposals), class: "help-text")
        html.html_safe
      end

      def form_method_for_attribute(attribute)
        return :editor if attribute.type.to_sym == :text && attribute.editor?

        TYPES[attribute.type.to_sym]
      end

      # Handles special cases.
      # Returns an empty Hash or a Hash with extra HTML options.
      def extra_options_for(field_name)
        case field_name
        when :participatory_texts_enabled
          participatory_texts_extra_options
        when :amendment_creation_enabled,
            :amendment_reaction_enabled,
            :amendment_promotion_enabled
          amendments_extra_options
        else
          {}
        end
      end

      # Marks :participatory_texts_enabled setting with a CSS class if the
      # Proposals component has existing proposals, so it can be identified
      # in "decidim/admin/form.js". Also, adds a help_text.
      def participatory_texts_extra_options
        return {} unless Decidim::Proposals::Proposal.where(component: @component).any?

        {
          class: "participatory_texts_disabled",
          help_text: help_text_for_component_setting(:participatory_texts_disabled, :global, :proposals)
        }
      end

      # Marks component_step_settings related to amendments with a CSS class,
      # so they can be identified in "decidim/admin/form.js".
      def amendments_extra_options
        { class: "amendments_step_settings" }
      end
    end
  end
end
