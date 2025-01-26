# frozen_string_literal: true

module Decidim
  module Initiatives
    # A Helper to render scopes, including a global scope, for forms.
    module ScopesHelper
      include DecidimFormHelper
      include TranslatableAttributes

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
