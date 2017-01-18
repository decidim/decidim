# frozen_string_literal: true

module Decidim
  module Meetings
    # Exposes the meeting resource so users can view them
    class MeetingsController < Decidim::Meetings::ApplicationController
      include FilterResource

      helper_method :meetings, :meeting

      def index; end

      private

      def meetings
        @meetings ||= search.results
      end

      def meeting
        @meeting ||= meetings.find(params[:id])
      end

      def search_klass
        MeetingSearch
      end

      def default_search_params
        {
          page: params[:page],
          per_page: 12
        }
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
        {feature: current_feature, organization: current_organization }
      end
    end
  end
end
