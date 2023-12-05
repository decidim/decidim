# frozen_string_literal: true

require "cell/partial"

module Decidim
  module Meetings
    # This cell renders the highlighted meetings for a given component.
    # It is intended to be used in the `participatory_space_highlighted_elements`
    # view hook.
    class HighlightedMeetingsForComponentCell < Decidim::ViewModel
      include Decidim::Meetings::ApplicationHelper
      include Decidim::ComponentPathHelper
      include Decidim::CardHelper
      include Decidim::LayoutHelper

      delegate :snippets, to: :controller

      def show
        render unless items_blank?
      end

      def items_blank?
        meetings_count.zero?
      end

      private

      def meetings_count
        @meetings_count ||= meetings.size
      end

      def base_relation
        @base_relation ||= Decidim::Meetings::Meeting.where(component: model)
                                                     .except_withdrawn
                                                     .published
                                                     .not_hidden
                                                     .visible_for(current_user)
      end

      def section_id
        return "upcoming_meetings" if show_upcoming_meetings?

        "past_meetings"
      end

      def collection
        @collection ||= meetings.limit(limit)
      end

      def meetings
        @meetings ||= show_upcoming_meetings? ? upcoming_meetings : past_meetings
      end

      def title
        return t("upcoming_meetings", scope: "decidim.participatory_spaces.highlighted_meetings") if show_upcoming_meetings?

        t("past_meetings", scope: "decidim.participatory_spaces.highlighted_meetings")
      end

      def show_upcoming_meetings?
        @show_upcoming_meetings ||= options[:force_upcoming] || upcoming_meetings.present?
      end

      def show_map?
        maps_active? && !all_online_meetings?
      end

      def maps_active?
        Decidim::Map.available?(:geocoding, :dynamic)
      end

      def all_online_meetings?
        collection.collect(&:type_of_meeting).all?("online")
      end

      def show_calendar?
        @show_calendar ||= show_upcoming_meetings? && collection.minimum(:start_time).before?(2.months.from_now.beginning_of_month)
      end

      def calendar_months
        [Date.current, Date.current.next_month]
      end

      def past_meetings
        @past_meetings ||= base_relation.past.order(end_time: :desc, start_time: :desc)
      end

      def upcoming_meetings
        @upcoming_meetings ||= base_relation.upcoming.order(:start_time, :end_time)
      end

      def single_component?
        @single_component ||= model.is_a?(Decidim::Component)
      end

      def cache_hash
        hash = []
        hash << "decidim/meetings/highlighted_meetings_for_component"
        hash << meetings.cache_key_with_version
        hash.push(current_user.try(:id))
        hash << I18n.locale.to_s
        hash.join(Decidim.cache_key_separator)
      end

      def component_routes
        Decidim::EngineRouter.main_proxy(model)
      end

      def limit
        3
      end

      def see_all_path
        @see_all_path ||= options[:see_all_path] || (single_component? && main_component_path(model))
      end
    end
  end
end
