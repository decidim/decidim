# frozen_string_literal: true

module Decidim
  module Admin
    # This class contains helpers needed in order for component settings to
    # properly render.
    module SettingsHelper
      include Decidim::ScopesHelper

      TYPES = {
        boolean: :check_box,
        integer: :number_field,
        string: :text_field,
        text: :text_area,
        select: :select_field,
        scope: :scope_field,
        enum: :collection_radio_buttons,
        time: :datetime_field
      }.freeze

      # Renders a form field that matches a settings attribute's type.
      # Besides the field itself, it also renders all the metadata (like the labels and help texts)
      #
      # @param form [Decidim::Admin::FormBuilder] The form in which to render the field
      # @param attribute [Decidim::SettingsManifest::Attribute] The Settings::Attribute instance with the
      #   description of the attribute.
      # @param name [Symbol] The name of the field.
      # @param i18n_scope [String] The scope where it'll find all the texts for the internationalization (locales)
      # @param options [Hash] Extra options to be passed to the field helper.
      # @option options [String] :tabs_prefix The type of the setting.
      #   It can be "global-settings" or "step-N-settings", where N is the number of the step.
      # @option options [nil, Boolean] :readonly True if the input is readonly.
      # @return [ActiveSupport::SafeBuffer] Rendered form field.
      def settings_attribute_input(form, attribute, name, i18n_scope, options = {})
        form_method = form_method_for_attribute(attribute)

        container_class = "#{name}_container"
        if options[:readonly]
          container_class += " readonly_container"
          help_text = text_for_setting(name, "readonly", i18n_scope)
        end
        help_text ||= text_for_setting(name, "help", i18n_scope)
        help_text_options = help_text ? { help_text: } : {}

        options = { label: t(name, scope: i18n_scope) }
                  .merge(help_text_options)
                  .merge(extra_options_for_type(form_method))
                  .merge(options)

        content_tag(:div, class: container_class) do
          if attribute.translated?
            options[:tabs_id] = "#{options.delete(:tabs_prefix)}-#{name}-tabs"
            form.send(:translated, form_method, name, options)
          elsif form_method == :collection_radio_buttons
            render_enum_form_field(form, attribute, name, i18n_scope, options)
          elsif form_method == :select_field
            render_select_form_field(form, attribute, name, i18n_scope, options)
          elsif form_method == :scope_field
            scopes_picker_field(form, name)
          else
            form.send(form_method, name, options)
          end
        end.html_safe
      end

      private

      # Renders a select field collection input for the given attribute
      #
      # @param form (see #settings_attribute_input)
      # @param attribute (see #settings_attribute_input)
      # @param name (see #settings_attribute_input)
      # @param i18n_scope (see #settings_attribute_input)
      # @param options (see #settings_attribute_input)
      # @option :tabs_prefix (see #settings_attribute_input)
      # @option :readonly (see #settings_attribute_input)
      # @option options [String] :label The label that this field has
      # @option options [String] :help_text The help text shown after the input field
      # @return (see #settings_attribute_input)
      def render_select_form_field(form, attribute, name, i18n_scope, options)
        html = form.select(
          name,
          attribute.build_choices.map { |o| [t("#{name}_options.#{o}", scope: i18n_scope), o] },
          { include_blank: attribute.include_blank, label: options[:label] }
        )
        html << content_tag(:p, options[:help_text], class: "help-text") if options[:help_text]
        html
      end

      # Returns a radio buttons collection input for the given attribute
      #
      # @param form (see #settings_attribute_input)
      # @param attribute (see #settings_attribute_input)
      # @param name (see #settings_attribute_input)
      # @param i18n_scope (see #settings_attribute_input)
      # @param options (see #settings_attribute_input)
      # @option :tabs_prefix (see #settings_attribute_input)
      # @option :readonly (see #settings_attribute_input)
      # @option :label (see #render_select_form_field)
      # @option :help_text (see #render_select_form_field)
      # @return (see #settings_attribute_input)
      def render_enum_form_field(form, attribute, name, i18n_scope, options)
        html = label_tag(name) do
          concat options[:label]
          concat tag(:br)
          concat form.collection_radio_buttons(name,
                                               build_enum_choices(name, i18n_scope, attribute.build_choices),
                                               :last,
                                               :first,
                                               { checked: form.object.send(name) },
                                               options) { |b| b.label { b.radio_button + b.text } }
        end
        html << content_tag(:p, options[:help_text], class: "help-text") if options[:help_text]
        html
      end

      # Get the translation for a given attribute
      # Returns a translation or nil. If nil, ZURB Foundation won't add the help_text.
      #
      # @param name (see #settings_attribute_input)
      # @param suffix [String] What suffix the i18n key has
      # @param i18n_scope (see #settings_attribute_input)
      # @return [String, nil]
      def text_for_setting(name, suffix, i18n_scope)
        html_key = "#{i18n_scope}.#{name}_#{suffix}_html"
        return t(html_key) if I18n.exists?(html_key)

        key = "#{i18n_scope}.#{name}_#{suffix}"
        return t(key) if I18n.exists?(key)
      end

      # Which form method is being used for this attribute
      #
      # @param attribute [Decidim::SettingsManifest::Attribute]
      # @return [Symbol] The FormBuilder's method used to render
      def form_method_for_attribute(attribute)
        return :editor if attribute.type.to_sym == :text && attribute.editor?

        TYPES[attribute.type.to_sym]
      end

      # Handles special cases.
      #
      # @param input_type [Symbol]
      # @return [Hash] Empty Hash or a Hash with extra HTML options.
      def extra_options_for_type(input_type)
        case input_type
        when :text_area
          { rows: 6 }
        else
          {}
        end
      end

      # Build options for enum attributes
      # Get the translation for a given attribute of type choice
      #
      # @param name (see #settings_attribute_input)
      # @param i18n_scope (see #settings_attribute_input)
      # @param choices [Array<Symbol>]
      # @return [Array<Array<String>>]
      def build_enum_choices(name, i18n_scope, choices)
        choices.map do |choice|
          [t("#{name}_choices.#{choice}", scope: i18n_scope), choice]
        end
      end
    end
  end
end
