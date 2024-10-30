# frozen_string_literal: true

module Decidim
  # This helper include some methods for rendering a checkboxes tree input.
  module CheckBoxesTreeHelper
    include SanitizeHelper

    # This method returns a hash with the options for the checkbox and its label
    # used in filters that uses checkboxes trees
    def check_boxes_tree_options(value, label, **options)
      parent_id = options.delete(:parent_id) || ""
      object = options.delete(:object)
      checkbox_options = {
        value:,
        label:,
        multiple: true,
        include_hidden: false,
        label_options: {
          "data-children-checkbox": parent_id,
          value:,
          for: "#{options[:namespace]}_#{options[:id]}"
        }
      }
      options.merge!(checkbox_options)
      # as taxonomies work with a nested array of values, we need to manually check if the value is checked
      matches = options[:id]&.match(/^with_any_taxonomies_([0-9]+)__taxonomy-([0-9_]+)/)
      if matches.present? && object.respond_to?(:with_any_taxonomies) && object.with_any_taxonomies&.dig(matches[1]).is_a?(Array)
        options[:checked] = object.with_any_taxonomies[matches[1]].include?(value.to_s)
      end

      if options.delete(:is_root_check_box) == true
        options[:label_options].merge!("data-global-checkbox": "")
        options[:label_options].delete(:"data-children-checkbox")
      end

      options
    end

    # struct for nodes of checkboxes trees
    TreeNode = Struct.new(:leaf, :node) do
      def tree_node?
        is_a?(TreeNode)
      end
    end

    # struct for leafs of checkboxes trees
    TreePoint = Struct.new(:value, :label, :root) do
      def tree_node?
        is_a?(TreeNode)
      end

      def root?
        root.present? || value.blank?
      end
    end

    # Overwrite this method in your component helper to define
    # origin values.
    def filter_origin_values
      raise StandardError, "Not implemented"
    end

    def filter_taxonomy_values_for(taxonomy_filter)
      taxonomies = filter_taxonomy_values_children(taxonomy_filter.taxonomies)
      TreeNode.new(
        TreePoint.new(taxonomy_filter.root_taxonomy_id, t("decidim.core.application_helper.filter_taxonomy_values.all"), true),
        taxonomies
      )
    end

    def filter_taxonomy_values_children(children)
      children.map do |id, hash|
        TreeNode.new(
          TreePoint.new(id, decidim_escape_translated(hash[:taxonomy].name).html_safe),
          filter_taxonomy_values_children(hash[:children])
        )
      end
    end

    # pending initiatives removal
    def filter_global_scopes_values
      filter_scopes_values_from(current_organization.scopes.top_level)
    end

    # pending initiatives removal
    def filter_areas_values
      areas_or_types = areas_for_select(current_organization)

      areas_values = if areas_or_types.first.is_a?(Decidim::Area)
                       filter_areas(areas_or_types)
                     else
                       filter_areas_and_types(areas_or_types)
                     end

      TreeNode.new(
        TreePoint.new("", t("decidim.core.application_helper.filter_area_values.all")),
        areas_values
      )
    end

    def filter_tree_from_array(array)
      root_point = if array.first[0].blank?
                     TreePoint.new(*array.shift)
                   else
                     TreePoint.new("", t("decidim.core.application_helper.filter_scope_values.all"))
                   end
      TreeNode.new(
        root_point,
        array.map { |values| TreePoint.new(*values) }
      )
    end

    def flat_filter_values(*types, **options)
      scope = options[:scope]
      types.map do |type|
        [type, t(type, scope:)]
      end
    end

    def filter_text_for(translation, id: nil)
      content_tag(:span, translation, id:).html_safe + content_tag(:span)
    end

    private

    def filter_scopes_values_from(scopes, participatory_space = nil)
      scopes_values = scopes.compact.flat_map do |scope|
        TreeNode.new(
          TreePoint.new(scope.id.to_s, translated_attribute(scope.name)),
          scope_children_to_tree(scope, participatory_space)
        )
      end

      scopes_values.prepend(TreePoint.new("global", t("decidim.scopes.global"))) if participatory_space&.scope.blank?

      filter_tree_from(scopes_values)
    end

    def scope_children_to_tree(scope, participatory_space = nil)
      return if participatory_space.present? && scope.scope_type && scope.scope_type == current_participatory_space.try(:scope_type_max_depth)
      return unless scope.children.any?

      scope.children.includes(:scope_type, :children).flat_map do |child|
        TreeNode.new(
          TreePoint.new(child.id.to_s, translated_attribute(child.name)),
          scope_children_to_tree(child, participatory_space)
        )
      end
    end

    def filter_tree_from(scopes_values)
      TreeNode.new(
        TreePoint.new("", t("decidim.core.application_helper.filter_scope_values.all")),
        scopes_values
      )
    end

    def filter_areas(areas)
      areas.map do |area|
        TreeNode.new(
          TreePoint.new(area.id.to_s, area.name[I18n.locale.to_s])
        )
      end
    end

    def filter_areas_and_types(area_types)
      area_types.map do |area_type|
        TreeNode.new(
          TreePoint.new(area_type.area_ids.join("_"), area_type.name[I18n.locale.to_s]),
          area_type.areas.map do |area|
            TreePoint.new(area.id.to_s, area.name[I18n.locale.to_s])
          end
        )
      end
    end
  end
end
