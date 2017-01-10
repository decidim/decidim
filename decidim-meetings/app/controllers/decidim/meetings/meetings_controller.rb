# frozen_string_literal: true

module Decidim
  module Meetings
    # Exposes the meeting resource so users can view them
    class MeetingsController < Decidim::Meetings::ApplicationController
      helper_method :meetings, :meeting, :search_params, :filter

      def index
      end

      private

      def meetings
        @meetings ||= MeetingsSearch.new(search_params.merge(context_params)).results
      end

      def meeting
        @meeting ||= meetings.find(params[:id])
      end

      def search_params
        default_search_params
          .merge(params.to_unsafe_h.except(:filter))
          .merge(params.to_unsafe_h[:filter] || {})
      end

      def filter
        @filter ||= filter_klass.new(params.dig(:filter, :category_id), params[:order_start_time], params[:scope_id])
      end

      # Internal: Defines a class that will wrap in an object the URL params used by the filter.
      # this way we can use Rails' form helpers and have automatically checked checkboxes and
      # radio buttons in the view, for example.
      def filter_klass
        Struct.new(:category_id, :order_start_time, :scope_id)
      end

      def default_search_params
        {
          order_start_time: "asc"
        }.with_indifferent_access
      end

      def context_params
        {
          feature: current_feature
        }
      end
    end
  end
end
