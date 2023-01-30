# frozen_string_literal: true

require "cell/partial"

module Decidim
  module Meetings
    # This cell renders the highlighted meetings for a given component.
    # It is intended to be used in the `participatory_space_highlighted_elements`
    # view hook.
    class HighlightedMeetingsForComponentCell < Decidim::ViewModel
      include ApplicationHelper
      include Decidim::ComponentPathHelper
      include Decidim::CardHelper
      include Decidim::LayoutHelper

      delegate :snippets, to: :controller

      def show
        render unless meetings_count.zero?
      end

      private

      def meetings
        @meetings ||= Decidim::Meetings::Meeting.where(component: model)
                                                .except_withdrawn
                                                .published
                                                .not_hidden
                                                .visible_for(current_user)
      end

      def section_id
        return "upcoming_meetings" if upcoming_meetings?
        return "past_meetings" if past_meetings?
      end

      def collection
        return upcoming_meetings if upcoming_meetings?
        return past_meetings if past_meetings?
      end

      def title
        return t("upcoming_meetings", scope: "decidim.participatory_spaces.highlighted_meetings") if upcoming_meetings?
        return t("past_meetings", scope: "decidim.participatory_spaces.highlighted_meetings") if past_meetings?
      end

      def upcoming_meetings?
        @upcoming_meetings_present ||= upcoming_meetings.present?
      end

      def past_meetings?
        @past_meetings_present ||= past_meetings.present?
      end

      def past_meetings
        @past_meetings ||= meetings.past.order(end_time: :desc, start_time: :desc).limit(3)
      end

      def upcoming_meetings
        @upcoming_meetings ||= meetings.upcoming.order(:start_time, :end_time).limit(3)
      end

      def meetings_count
        @meetings_count ||= meetings.count
      end

      def past_meetings_count
        @past_meetings_count ||= meetings.past.count
      end

      def upcoming_meetings_count
        @upcoming_meetings_count ||= meetings.upcoming.count
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
    end
  end
end
