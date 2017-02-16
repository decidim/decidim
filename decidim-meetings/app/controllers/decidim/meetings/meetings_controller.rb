# frozen_string_literal: true

module Decidim
  module Meetings
    # Exposes the meeting resource so users can view them
    class MeetingsController < Decidim::Meetings::ApplicationController
      include FilterResource

      helper_method :meeting

      def index
        results = search.results

        if !params[:filter] && results.length == 0
          params[:filter] = {
            date: "past",
            meetings_warning: true
          }
          results = search_klass.new(search_params).results
          if results.length == 0
            params[:filter] = {
              date: "past",
              meetings_warning: true,
              meetings_alert: true
            }
            results = search_klass.new(search_params).results
          end
        end

        params[:filter] ||= {}
        @meetings_alert = params[:filter]["meetings_alert"]
        @meetings_warning = params[:filter]["meetings_warning"]
        @meetings = results.page(params[:page]).per(12)
        @geocoded_meetings = results.select(&:geocoded?)
      end

      def static_map
        @meeting = Meeting.where(feature: current_feature).find(params[:id])
        send_data StaticMapGenerator.new(@meeting).data, type: "image/jpeg", disposition: "inline"
      end

      private

      def meeting
        @meeting ||= Meeting.where(feature: current_feature).find(params[:id])
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
