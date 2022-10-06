# frozen_string_literal: true

module Decidim
  module Meetings
    # Custom helpers, scoped to the meetings engine.
    #
    module ApplicationHelper
      include PaginateHelper
      include Decidim::MapHelper
      include Decidim::Meetings::MapHelper
      include Decidim::Comments::CommentsHelper
      include Decidim::SanitizeHelper
      include Decidim::CheckBoxesTreeHelper
      include Decidim::RichTextEditorHelper

      def filter_origin_values
        origin_values = []
        origin_values << TreePoint.new("official", t("decidim.meetings.meetings.filters.origin_values.official"))
        origin_values << TreePoint.new("participants", t("decidim.meetings.meetings.filters.origin_values.participants")) # todo
        if current_organization.user_groups_enabled?
          origin_values << TreePoint.new("user_group", t("decidim.meetings.meetings.filters.origin_values.user_groups")) # todo
        end
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
        [
          ["all", t("decidim.meetings.meetings.filters.date_values.all")],
          ["upcoming", t("decidim.meetings.meetings.filters.date_values.upcoming")],
          ["past", t("decidim.meetings.meetings.filters.date_values.past")]
        ]
      end

      # Options to filter meetings by activity.
      def activity_filter_values
        [
          ["all", t("decidim.meetings.meetings.filters.all")],
          ["my_meetings", t("decidim.meetings.meetings.filters.my_meetings")]
        ]
      end

      # If the meeting is official or the rich text editor is enabled on the
      # frontend, the meeting body is considered as safe content; that's unless
      # the meeting comes from a collaborative_draft or a participatory_text.
      def safe_content?
        rich_text_editor_in_public_views? || @meeting.official?
      end

      # If the content is safe, HTML tags are sanitized, otherwise, they are stripped.
      def render_meeting_body(meeting)
        Decidim::ContentProcessor.render(render_sanitized_content(meeting, :description), "div")
      end

      def prevent_timeout_seconds
        return 0 unless respond_to?(:meeting)
        return 0 if !current_user || !meeting || !meeting.live?
        return 0 unless online_or_hybrid_meeting?(meeting)
        return 0 unless iframe_embed_or_live_event_page?(meeting)
        return 0 unless meeting.iframe_access_level_allowed_for_user?(current_user)

        (meeting.end_time - Time.current).to_i
      end

      def online_or_hybrid_meeting?(meeting)
        meeting.online_meeting? || meeting.hybrid_meeting?
      end

      def iframe_embed_or_live_event_page?(meeting)
        %w(embed_in_meeting_page open_in_live_event_page).include? meeting.iframe_embed_type
      end
    end
  end
end
