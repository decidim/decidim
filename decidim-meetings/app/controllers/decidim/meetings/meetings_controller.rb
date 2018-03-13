# frozen_string_literal: true

module Decidim
  module Meetings
    # Exposes the meeting resource so users can view them
    class MeetingsController < Decidim::Meetings::ApplicationController
      include FilterResource
      include Paginable
      helper Decidim::WidgetUrlsHelper

      helper_method :meetings, :geocoded_meetings, :meeting

      def index
        return unless search.results.empty? && params.dig("filter", "date") != "past"

        @past_meetings = search_klass.new(search_params.merge(date: "past"))
        unless @past_meetings.results.empty?
          params[:filter] ||= {}
          params[:filter][:date] = "past"
          @forced_past_meetings = true
          @search = @past_meetings
        end
      end

      private

      def meeting
        @meeting ||= Meeting.where(component: current_component).find(params[:id])
      end

      def meetings
        @meetings ||= paginate(search.results)
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
        { component: current_component, organization: current_organization }
      end
    end
  end
end
