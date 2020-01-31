# frozen_string_literal: true

module Decidim
  # This helper include some methods for rendering resources static and dynamic maps.
  module ChainedCheckBoxesHelper
    # This method returns a hash with the options for the checkbox and its label
    # used in filters that uses chained checkboxes
    def chained_check_box_options(value, label, **options)
      checkbox_options = {
        value: value,
        label: label,
        multiple: true,
        include_hidden: false,
        label_options: {
          "data-children-checkbox": "",
          value: value
        }
      }
      options.merge!(checkbox_options)

      if options[:is_root_check_box] == true
        options[:label_options].merge!("data-global-checkbox": "")
        options[:label_options].delete(:"data-children-checkbox")
      end
      options[:label_options].delete(:is_root_check_box)

      options
    end

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

    def filter_origin_values
      origin_values = []
      origin_values << TreePoint.new("official", t("decidim.proposals.application_helper.filter_origin_values.official")) if component_settings.official_proposals_enabled
      origin_values << TreePoint.new("citizens", t("decidim.proposals.application_helper.filter_origin_values.citizens"))
      origin_values << TreePoint.new("user_group", t("decidim.proposals.application_helper.filter_origin_values.user_groups")) if current_organization.user_groups_enabled?
      origin_values << TreePoint.new("meeting", t("decidim.proposals.application_helper.filter_origin_values.meetings"))

      TreeNode.new(
        TreePoint.new("", t("decidim.proposals.application_helper.filter_origin_values.all")),
        origin_values
      )
    end

    def filter_state_values
      TreeNode.new(
        TreePoint.new("", t("decidim.proposals.application_helper.filter_state_values.all")),
        [
          TreePoint.new("accepted", t("decidim.proposals.application_helper.filter_state_values.accepted")),
          TreePoint.new("evaluating", t("decidim.proposals.application_helper.filter_state_values.evaluating")),
          TreePoint.new("not_answered", t("decidim.proposals.application_helper.filter_state_values.not_answered")),
          TreePoint.new("rejected", t("decidim.proposals.application_helper.filter_state_values.rejected"))
        ]
      )
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
        TreePoint.new("", t("decidim.proposals.application_helper.filter_category_values.all")),
        categories_values
      )
    end

    def filter_scopes_values
      main_scopes = current_participatory_space.scope.presence || current_participatory_space.scopes.top_level

      scopes_values = main_scopes.flat_map do |scope|
        TreeNode.new(
          TreePoint.new(scope.id.to_s, translated_attribute(scope.name, current_participatory_space.organization)),
          scope_children_to_tree(scope)
        )
      end

      TreeNode.new(
        TreePoint.new("", t("decidim.proposals.application_helper.filter_scope_values.all")),
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
