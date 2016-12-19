# frozen_string_literal: true

module Decidim
  module Meetings
    # This controller is the abstract class from which all other controllers of
    # this engine inherit.
    #
    # Note that it inherits from `Decidim::Features::BaseController`, which
    # override its layout and provide all kinds of useful methods.
    class MeetingsController < Decidim::Meetings::ApplicationController
      helper_method :meetings, :meeting

      private

      def meetings
        @meetings ||= MeetingsSearch.new(current_feature: current_feature, order_start_time: :asc).results
      end

      def meeting
        @meeting ||= meetings.find(params[:id])
      end
    end
  end
end
