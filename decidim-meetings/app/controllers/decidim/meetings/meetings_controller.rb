# frozen_string_literal: true

module Decidim
  module Meetings
    # This controller is the abstract class from which all other controllers of
    # this engine inherit.
    #
    # Note that it inherits from `Decidim::Components::BaseController`, which
    # override its layout and provide all kinds of useful methods.
    class MeetingsController < Decidim::Meetings::ApplicationController
      def index
        @meetings = Meeting.where(decidim_component_id: current_component.id)
      end

      def show
        @meeting = Meeting.find_by(component: current_component)
      end
    end
  end
end
