# frozen_string_literal: true

module Decidim
  module Meetings
    # Custom helpers, scoped to the meetings engine.
    #
    module ApplicationHelper
      include PaginateHelper
      include Decidim::MapHelper
      include Decidim::Meetings::MapHelper
      include Decidim::Meetings::MeetingsHelper
      include Decidim::Comments::CommentsHelper
      include Decidim::SanitizeHelper
      include Decidim::CheckBoxesTreeHelper

      def filter_origin_values
        origin_values = []
        origin_values << TreePoint.new("official", t("decidim.meetings.meetings.filters.origin_values.official"))
        origin_values << TreePoint.new("citizens", t("decidim.meetings.meetings.filters.origin_values.citizens")) # todo
        # if component_settings enabled enabled
        origin_values << TreePoint.new("user_group", t("decidim.meetings.meetings.filters.origin_values.user_groups")) # todo
        # if current_organization.user_groups_enabled? and component_settings enabled enabled

        TreeNode.new(
          TreePoint.new("", t("decidim.meetings.meetings.filters.origin_values.all")),
          origin_values
        )
      end

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
        TreeNode.new(
          TreePoint.new("", t("decidim.meetings.meetings.filters.date_values.all")),
          [
            TreePoint.new("upcoming", t("decidim.meetings.meetings.filters.date_values.upcoming")),
            TreePoint.new("past", t("decidim.meetings.meetings.filters.date_values.past"))
          ]
        )
      end

      # Options to filter meetings by activity.
      def activity_filter_values
        [
          ["all", t("decidim.meetings.meetings.filters.all")],
          ["my_meetings", t("decidim.meetings.meetings.filters.my_meetings")]
        ]
      end
    end
  end
end
