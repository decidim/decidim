# frozen_string_literal: true

module Decidim
  module Meetings
    # This controller is the abstract class from which all other controllers of
    # this engine inherit.
    #
    # Note that it inherits from `Decidim::Features::BaseController`, which
    # override its layout and provide all kinds of useful methods.
    class MeetingsController < Decidim::Meetings::ApplicationController
      helper_method :meetings, :meeting, :search_params

      def index
        respond_to do |format|
          format.html
          format.js
        end
      end

      private

      def meetings
        @meetings ||= MeetingsSearch.new(search_params.merge(feature_id: current_feature.id)).results
      end

      def meeting
        @meeting ||= meetings.find(params[:id])
      end

      def search_params
        default_search_params.merge(params.to_unsafe_h)
      end

      def default_search_params
        {
          order_start_time: "asc"
        }.with_indifferent_access
      end
    end
  end
end
