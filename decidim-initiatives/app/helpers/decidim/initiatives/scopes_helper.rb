# frozen_string_literal: true

module Decidim
  module Initiatives
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

      def ordered_scopes_descendants(root = nil)
        root = try(:current_participatory_space)&.scope if root == false
        if root.present?
          root.descendants
        else
          current_organization.scopes
        end.sort { |a, b| a.part_of.reverse <=> b.part_of.reverse }
      end

      def ordered_scopes_descendants_for_select(root = nil)
        ordered_scopes_descendants(root).map do |scope|
          [" #{"&nbsp;" * 4 * (scope.part_of.count - 1)} #{translated_attribute(scope.name)}".html_safe, scope&.id]
        end
      end
    end
  end
end
