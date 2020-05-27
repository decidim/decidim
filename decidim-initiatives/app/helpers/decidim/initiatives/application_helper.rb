# frozen_string_literal: true

module Decidim
  module Initiatives
    # Custom helpers, scoped to the initiatives engine.
    #
    module ApplicationHelper
      include Decidim::CheckBoxesTreeHelper

      def filter_states_values
        TreeNode.new(
          TreePoint.new("", t("decidim.initiatives.application_helper.filter_state_values.all")),
          [
            TreePoint.new("open", t("decidim.initiatives.application_helper.filter_state_values.open")),
            TreeNode.new(
              TreePoint.new("closed", t("decidim.initiatives.application_helper.filter_state_values.closed")),
              [
                TreePoint.new("accepted", t("decidim.initiatives.application_helper.filter_state_values.accepted")),
                TreePoint.new("rejected", t("decidim.initiatives.application_helper.filter_state_values.rejected"))
              ]
            ),
            TreePoint.new("answered", t("decidim.initiatives.application_helper.filter_state_values.answered"))
          ]
        )
      end

      def filter_scopes_values
        main_scopes = current_organization.scopes.top_level

        scopes_values = main_scopes.includes(:scope_type, :children).flat_map do |scope|
          TreeNode.new(
            TreePoint.new(scope.id.to_s, translated_attribute(scope.name, current_organization)),
            scope_children_to_tree(scope)
          )
        end

        scopes_values.prepend(TreePoint.new("global", t("decidim.scopes.global")))

        TreeNode.new(
          TreePoint.new("", t("decidim.initiatives.application_helper.filter_scope_values.all")),
          scopes_values
        )
      end

      def scope_children_to_tree(scope)
        return unless scope.children.any?

        scope.children.includes(:scope_type, :children).flat_map do |child|
          TreeNode.new(
            TreePoint.new(child.id.to_s, translated_attribute(child.name, current_organization)),
            scope_children_to_tree(child)
          )
        end
      end

      def filter_types_values
        types_values = Decidim::InitiativesType.where(organization: current_organization).map do |type|
          TreeNode.new(
            TreePoint.new(type.id.to_s, type.title[I18n.locale.to_s])
          )
        end

        TreeNode.new(
          TreePoint.new("", t("decidim.initiatives.application_helper.filter_type_values.all")),
          types_values
        )
      end
    end
  end
end
