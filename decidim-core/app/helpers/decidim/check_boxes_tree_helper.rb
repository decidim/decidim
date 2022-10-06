# frozen_string_literal: true

module Decidim
  # This helper include some methods for rendering a checkboxes tree input.
  module CheckBoxesTreeHelper
    # This method returns a hash with the options for the checkbox and its label
    # used in filters that uses checkboxes trees
    def check_boxes_tree_options(value, label, **options)
      checkbox_options = {
        value:,
        label:,
        multiple: true,
        include_hidden: false,
        label_options: {
          "data-children-checkbox": "",
          value:
        }
      }
      options.merge!(checkbox_options)

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
    TreePoint = Struct.new(:value, :label) do
      def tree_node?
        is_a?(TreeNode)
      end
    end

    # Overwrite this method in your component helper to define
    # origin values.
    def filter_origin_values
      raise StandardError, "Not implemented"
    end

    def filter_categories_values
      organization = current_participatory_space.organization

      sorted_main_categories = current_participatory_space.categories.first_class.includes(:subcategories).sort_by do |category|
        [category.weight, translated_attribute(category.name, organization)]
      end

      categories_values = sorted_main_categories.flat_map do |category|
        sorted_descendant_categories = category.descendants.includes(:subcategories).sort_by do |subcategory|
          [subcategory.weight, translated_attribute(subcategory.name, organization)]
        end

        subcategories = sorted_descendant_categories.flat_map do |subcategory|
          TreePoint.new(subcategory.id.to_s, translated_attribute(subcategory.name, organization))
        end

        TreeNode.new(
          TreePoint.new(category.id.to_s, translated_attribute(category.name, organization)),
          subcategories
        )
      end

      TreeNode.new(
        TreePoint.new("", t("decidim.proposals.application_helper.filter_category_values.all")),
        categories_values
      )
    end

    def resource_filter_scope_values(resource)
      if resource.is_a?(Scope)
        filter_scopes_values_from([resource])
      else
        filter_scopes_values
      end
    end

    def filter_scopes_values
      return filter_scopes_values_from_parent(current_component.scope) if current_component.scope.present?

      main_scopes = current_participatory_space.scopes.top_level
                                               .includes(:scope_type, :children)
      filter_scopes_values_from(main_scopes)
    end

    def filter_scopes_values_from_parent(scope)
      scopes_values = []
      scope.children.each do |child|
        unless child.children
          scopes_values << TreePoint.new(child.id.to_s, translated_attribute(child.name, current_participatory_space.organization))
          next
        end
        scopes_values << TreeNode.new(
          TreePoint.new(child.id.to_s, translated_attribute(child.name, current_participatory_space.organization)),
          scope_children_to_tree(child)
        )
      end

      filter_tree_from(scopes_values)
    end

    def filter_scopes_values_from(scopes)
      scopes_values = scopes.compact.flat_map do |scope|
        TreeNode.new(
          TreePoint.new(scope.id.to_s, translated_attribute(scope.name, current_participatory_space.organization)),
          scope_children_to_tree(scope)
        )
      end

      scopes_values.prepend(TreePoint.new("global", t("decidim.scopes.global"))) if current_participatory_space.scope.blank?

      filter_tree_from(scopes_values)
    end

    def scope_children_to_tree(scope)
      return if scope.scope_type && scope.scope_type == current_participatory_space.try(:scope_type_max_depth)
      return unless scope.children.any?

      scope.children.includes(:scope_type, :children).flat_map do |child|
        TreeNode.new(
          TreePoint.new(child.id.to_s, translated_attribute(child.name, current_participatory_space.organization)),
          scope_children_to_tree(child)
        )
      end
    end

    def filter_tree_from(scopes_values)
      TreeNode.new(
        TreePoint.new("", t("decidim.proposals.application_helper.filter_scope_values.all")),
        scopes_values
      )
    end
  end
end
