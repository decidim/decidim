# frozen_string_literal: true
require 'httparty'

module Decidim
  module Meetings
    # Exposes the meeting resource so users can view them
    class MeetingsController < Decidim::Meetings::ApplicationController
      include FilterResource

      helper_method :meetings, :meeting

      def index
        @geocoded_meetings = search.results.select(&:geocoded?)
      end

      def static_map
        @meeting = Meeting.where(feature: current_feature).find(params[:id])

        static_map_data = Rails.cache.fetch(@meeting.cache_key) do
          params = {
            c: "#{@meeting.latitude}, #{@meeting.longitude}",
            z: "15",
            w: "120",
            h: "120",
            f: "1",
            app_id: Rails.application.secrets.dig(:geocoder, "api_key").try(&:first),
            app_code: Rails.application.secrets.dig(:geocoder, "api_key").try(&:last)
          }

          uri = URI.parse('https://image.maps.cit.api.here.com/mia/1.6/mapview').tap do |uri|
            uri.query = URI.encode_www_form params
          end

          request = HTTParty.get(uri)
          request.body
        end

        send_data static_map_data, type: "image/jpeg", disposition: 'inline'
      end

      private

      def meetings
        @meetings ||= search.results.page(params[:page]).per(12)
      end

      def meeting
        @meeting ||= meetings.find(params[:id])
      end

      def search_klass
        MeetingSearch
      end

      def default_filter_params
        {
          order_start_time: "asc",
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
