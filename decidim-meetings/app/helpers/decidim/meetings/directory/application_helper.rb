# frozen_string_literal: true

module Decidim
  module Meetings
    # Custom helpers, scoped to the meetings engine.
    #
    module Directory
      module ApplicationHelper
        include PaginateHelper
        include Decidim::MapHelper
        include Decidim::Meetings::MapHelper
        include Decidim::Meetings::MeetingsHelper
        include Decidim::Comments::CommentsHelper
        include Decidim::SanitizeHelper
        include Decidim::CheckBoxesTreeHelper

        def filter_type_values
          type_values = []
          Decidim::Meetings::Meeting::TYPE_OF_MEETING.each do |type|
            type_values << TreePoint.new(type, t("decidim.meetings.meetings.filters.type_values.#{type}"))
          end

          TreeNode.new(
            TreePoint.new("", t("decidim.meetings.meetings.filters.type_values.all")),
            type_values
          )
        end

        def filter_date_values
          [
            ["all", t("decidim.meetings.meetings.filters.date_values.all")],
            ["upcoming", t("decidim.meetings.meetings.filters.date_values.upcoming")],
            ["past", t("decidim.meetings.meetings.filters.date_values.past")]
          ]
        end

        def directory_filter_scopes_values
          main_scopes = current_organization.scopes.top_level

          scopes_values = main_scopes.includes(:scope_type, :children).flat_map do |scope|
            TreeNode.new(
              TreePoint.new(scope.id.to_s, translated_attribute(scope.name, current_organization)),
              scope_children_to_tree(scope)
            )
          end

          scopes_values.prepend(TreePoint.new("global", t("decidim.scopes.global")))

          TreeNode.new(
            TreePoint.new("", t("decidim.meetings.application_helper.filter_scope_values.all")),
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

        def directory_meeting_spaces_values
          participatory_spaces = current_organization.public_participatory_spaces

          spaces = participatory_spaces.collect(&:model_name).uniq.map do |participatory_space|
            TreePoint.new(participatory_space.name.underscore, participatory_space.human(count: 2))
          end

          TreeNode.new(
            TreePoint.new("", t("decidim.meetings.application_helper.filter_meeting_space_values.all")),
            spaces
          )
        end

        def directory_filter_categories_values
          participatory_spaces = current_organization.public_participatory_spaces
          list_of_ps = participatory_spaces.flat_map do |current_participatory_space|
            next unless current_participatory_space.respond_to?(:categories)

            sorted_main_categories = current_participatory_space.categories.first_class.includes(:subcategories).sort_by do |category|
              [category.weight, translated_attribute(category.name, current_organization)]
            end

            categories_values = categories_values(sorted_main_categories)

            next if categories_values.empty?

            key_point = current_participatory_space.class.name.gsub("::", "__") + current_participatory_space.id.to_s

            TreeNode.new(
              TreePoint.new(key_point, translated_attribute(current_participatory_space.title, current_organization)),
              categories_values
            )
          end

          list_of_ps.compact!
          TreeNode.new(
            TreePoint.new("", t("decidim.meetings.application_helper.filter_category_values.all")),
            list_of_ps
          )
        end

        def directory_filter_origin_values
          origin_values = []
          origin_values << TreePoint.new("official", t("decidim.meetings.meetings.filters.origin_values.official"))
          origin_values << TreePoint.new("participants", t("decidim.meetings.meetings.filters.origin_values.participants"))
          origin_values << TreePoint.new("user_group", t("decidim.meetings.meetings.filters.origin_values.user_groups")) if current_organization.user_groups_enabled?

          TreeNode.new(
            TreePoint.new("", t("decidim.meetings.meetings.filters.origin_values.all")),
            origin_values
          )
        end

        # Options to filter meetings by activity.
        def activity_filter_values
          [
            ["all", t("decidim.meetings.meetings.filters.all")],
            ["my_meetings", t("decidim.meetings.meetings.filters.my_meetings")]
          ]
        end

        protected

        def categories_values(sorted_main_categories)
          sorted_main_categories.flat_map do |category|
            sorted_descendant_categories = category.descendants.includes(:subcategories).sort_by do |subcategory|
              [subcategory.weight, translated_attribute(subcategory.name, current_organization)]
            end

            subcategories = sorted_descendant_categories.flat_map do |subcategory|
              TreePoint.new(subcategory.id.to_s, translated_attribute(subcategory.name, current_organization))
            end

            TreeNode.new(
              TreePoint.new(category.id.to_s, translated_attribute(category.name, current_organization)),
              subcategories
            )
          end
        end
      end
    end
  end
end
