# frozen_string_literal: true

module Decidim
  module Meetings
    # This controller is the abstract class from which all other controllers of
    # this engine inherit.
    #
    # Note that it inherits from `Decidim::Features::BaseController`, which
    # override its layout and provide all kinds of useful methods.
    class MeetingsController < Decidim::Meetings::ApplicationController
      def index
        @meetings = Meeting.where(decidim_feature_id: current_feature.id)
      end

      def show
        @meeting = Meeting.find_by(feature: current_feature)
      end
    end
  end
end
