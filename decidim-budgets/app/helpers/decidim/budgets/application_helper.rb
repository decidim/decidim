# frozen_string_literal: true

module Decidim
  module Budgets
    # Custom helpers, scoped to the budgets engine.
    #
    module ApplicationHelper
      include PaginateHelper
      include Decidim::Comments::CommentsHelper
      include ProjectsHelper

      # struct for nodes of chained checkboxes
      TreeNode = Struct.new(:leaf, :node) do
        def tree_node?
          is_a?(TreeNode)
        end
      end

      # struct for leafs of chained checkboxes
      TreePoint = Struct.new(:value, :label) do
        def tree_node?
          is_a?(TreeNode)
        end
      end

      def filter_categories_values
        organization = current_participatory_space.organization

        sorted_main_categories = current_participatory_space.categories.first_class.includes(:subcategories).sort_by do |category|
          [category.weight, translated_attribute(category.name, organization)]
        end

        categories_values = sorted_main_categories.flat_map do |category|
          sorted_descendant_categories = category.descendants.sort_by do |subcategory|
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
          TreePoint.new("all", t("decidim.proposals.application_helper.filter_category_values.all")),
          categories_values
        )
      end

      def filter_scopes_values
        main_scopes = current_participatory_space.scopes.top_level

        scopes_values = main_scopes.flat_map do |scope|
          TreeNode.new(
            TreePoint.new(scope.id.to_s, translated_attribute(scope.name, current_participatory_space.organization)),
            scope_children_to_tree(scope)
          )
        end

        TreeNode.new(
          TreePoint.new("all", t("decidim.proposals.application_helper.filter_scope_values.all")),
          scopes_values
        )
      end

      def scope_children_to_tree(scope)
        return if scope.scope_type == current_participatory_space&.scope_type_max_depth
        return unless scope.children.any?

        scope.children.flat_map do |child|
          TreeNode.new(
            TreePoint.new(child.id.to_s, translated_attribute(child.name, current_participatory_space.organization)),
            scope_children_to_tree(child)
          )
        end
      end
    end
  end
end
