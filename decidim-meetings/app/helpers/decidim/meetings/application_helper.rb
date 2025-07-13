# frozen_string_literal: true

module Decidim
  module Meetings
    # Custom helpers, scoped to the meetings engine.
    #
    module ApplicationHelper
      include PaginateHelper
      include Decidim::MapHelper
      include Decidim::Comments::CommentsHelper
      include Decidim::SanitizeHelper
      include Decidim::CheckBoxesTreeHelper
      include Decidim::RichTextEditorHelper
      include ::Decidim::FollowableHelper

      def filter_origin_values
        origin_keys = %w(official participants)

        origin_values = flat_filter_values(*origin_keys, scope: "decidim.meetings.meetings.filters.origin_values")
        origin_values.prepend(["", t("all", scope: "decidim.meetings.meetings.filters.origin_values")])

        filter_tree_from_array(origin_values)
      end

      def filter_type_values
        type_values = flat_filter_values(*Decidim::Meetings::Meeting::TYPE_OF_MEETING.keys, scope: "decidim.meetings.meetings.filters.type_values").map do |args|
          TreePoint.new(*args)
        end

        TreeNode.new(
          TreePoint.new("", t("decidim.meetings.meetings.filters.type_values.all")),
          type_values
        )
      end

      def filter_date_values
        flat_filter_values(:all, :upcoming, :past, scope: "decidim.meetings.meetings.filters.date_values")
      end

      # rubocop:disable Metrics/ParameterLists
      # rubocop:disable Metrics/CyclomaticComplexity
      def filter_sections(date: false, type: false, origin: false, taxonomies: false, space_type: false, activity: false)
        @filter_sections ||= begin
          items = []
          if date
            items.append(method: :with_any_date, collection: filter_date_values, label: t("decidim.meetings.meetings.filters.date"), id: "date",
                         type: :radio_buttons)
          end
          items.append(method: :with_any_type, collection: filter_type_values, label: t("decidim.meetings.meetings.filters.type"), id: "type") if type
          if taxonomies
            available_taxonomy_filters.each do |taxonomy_filter|
              items.append(method: "with_any_taxonomies[#{taxonomy_filter.root_taxonomy_id}]",
                           collection: filter_taxonomy_values_for(taxonomy_filter),
                           label: decidim_sanitize_translated(taxonomy_filter.name),
                           id: "taxonomy-#{taxonomy_filter.root_taxonomy_id}")
            end
          end
          items.append(method: :with_any_origin, collection: filter_origin_values, label: t("decidim.meetings.meetings.filters.origin"), id: "origin") if origin
          if space_type
            items.append(method: :with_any_space, collection: directory_meeting_spaces_values, label: t("decidim.meetings.directory.meetings.index.space_type"),
                         id: "space_type")
          end
          if activity
            items.append(method: :activity, collection: activity_filter_values, label: t("decidim.meetings.meetings.filters.activity"), id: "activity",
                         type: :radio_buttons)
          end
          items.reject { |item| item[:collection].blank? }
        end
      end
      # rubocop:enable Metrics/ParameterLists
      # rubocop:enable Metrics/CyclomaticComplexity

      delegate :available_taxonomy_filters, to: :current_component

      # Options to filter meetings by activity.
      def activity_filter_values
        flat_filter_values(:all, :my_meetings, scope: "decidim.meetings.meetings.filters")
      end

      # If the meeting is official or the rich text editor is enabled on the
      # frontend, the meeting body is considered as safe content; that is unless
      # the meeting comes from a collaborative_draft or a participatory_text.
      def safe_content?
        rich_text_editor_in_public_views? || safe_content_admin?
      end

      # For admin entered content, the meeting body can contain certain extra
      # tags, such as iframes.
      def safe_content_admin?
        @meeting.official?
      end

      # If the content is safe, HTML tags are sanitized, otherwise, they are stripped.
      def render_meeting_body(meeting)
        render_meeting_sanitize_field(meeting, :description)
      end

      def render_meeting_sanitize_field(meeting, field)
        sanitized = render_sanitized_content(meeting, field)
        if safe_content?
          Decidim::ContentProcessor.render_without_format(sanitized).html_safe
        else
          Decidim::ContentProcessor.render(sanitized, "div")
        end
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
        meeting.online? || meeting.hybrid?
      end

      def iframe_embed_or_live_event_page?(meeting)
        %w(embed_in_meeting_page open_in_live_event_page).include? meeting.iframe_embed_type
      end

      def apply_meetings_pack_tags
        append_stylesheet_pack_tag("decidim_meetings", media: "all")
        append_javascript_pack_tag("decidim_meetings")
      end
    end
  end
end
