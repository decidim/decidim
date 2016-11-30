# frozen_string_literal: true
require "decidim/components/base_controller"

module Decidim
  module Meetings
    # This controller is the abstract class from which all other controllers of
    # this engine inherit.
    #
    # Note that it inherits from `Decidim::Components::Basecontroller`, which
    # override its layout and provide all kinds of useful methods.
    class ApplicationController < Decidim::Components::BaseController
      def show
        @meeting = Meeting.find_by(component: current_component)
      end
    end
  end
end
