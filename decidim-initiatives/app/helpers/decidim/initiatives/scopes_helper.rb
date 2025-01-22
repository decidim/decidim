# frozen_string_literal: true

module Decidim
  # A Helper to render scopes, including a global scope, for forms.
  module ScopesHelper
    include DecidimFormHelper
    include TranslatableAttributes

    # Retrieves the translated name and type for an scope.
    # scope - a Decidim::Scope
    # global_name - text to use when scope is nil
    #
    # Returns a string
    def scope_name_for_picker(scope, global_name)
      return global_name unless scope

      name = translated_attribute(scope.name)
      name << " (#{translated_attribute(scope.scope_type.name)})" if scope.scope_type
      name
    end

    # Renders a scopes select field in a form.
    # form - FormBuilder object
    # name - attribute name
    # options       - An optional Hash with options:
    #
    # Returns nothing.
    def scopes_select_field(form, name, root: false, options: {}, html_options: {})
      options = options.merge(include_blank: I18n.t("decidim.scopes.prompt")) unless options.has_key?(:include_blank)

      form.select(
        name,
        ordered_scopes_descendants_for_select(root),
        options,
        html_options
      )
    end

    def scopes_select_tag(name, root: false, options: {})
      select_tag(
        name,
        options_for_select(ordered_scopes_descendants_for_select(root)),
        options.merge(include_blank: I18n.t("decidim.scopes.prompt"))
      )
    end

    # Renders a scopes picker field in a filter form.
    # form - FilterFormBuilder object
    # name - attribute name
    # help_text - The help text to display
    # checkboxes_on_top - Show picker values on top (default) or below the picker prompt (only for multiple pickers)
    #
    # Returns nothing.
    def scopes_picker_filter(form, name, help_text: nil, checkboxes_on_top: true)
      options = {
        multiple: true,
        legend_title: I18n.t("decidim.scopes.scopes"),
        label: false,
        help_text:,
        checkboxes_on_top:
      }

      form.scopes_picker name, options do |scope|
        {
          url: decidim.scopes_picker_path(
            root: try(:current_participatory_space).try(:scope),
            current: scope&.id,
            title: I18n.t("decidim.scopes.prompt"),
            global_value: "global",
            max_depth: try(:current_participatory_space).try(:scope_type_max_depth)
          ),
          text: scope_name_for_picker(scope, I18n.t("decidim.scopes.prompt"))
        }
      end
    end
  end
end
