# frozen_string_literal: true

module Decidim
  module Meetings
    # Exposes the meeting resource so users can view them
    class MeetingsController < Decidim::Meetings::ApplicationController
      include FilterResource

      helper Decidim::WidgetUrlsHelper

      helper_method :meetings, :geocoded_meetings, :meeting

      def index
        if search.results.empty? && params.dig("filter", "date") != "past"
          @past_meetings = search_klass.new(search_params.merge(date: "past"))
          unless @past_meetings.results.empty?
            params[:filter] ||= {}
            params[:filter][:date] = "past"
            @forced_past_meetings = true
            @search = @past_meetings
          end
        end
      end

      private

      def meeting
        @meeting ||= Meeting.where(feature: current_feature).find(params[:id])
      end

      def meetings
        @meetings ||= search.results.page(params[:page]).per(12)
      end

      def geocoded_meetings
        @geocoded_meetings ||= search.results.select(&:geocoded?)
      end

      def search_klass
        MeetingSearch
      end

      def default_filter_params
        {
          date: "upcoming",
          search_text: "",
          scope_id: "",
          category_id: ""
        }
      end

      def context_params
        { feature: current_feature, organization: current_organization }
      end
    end
  end
end
