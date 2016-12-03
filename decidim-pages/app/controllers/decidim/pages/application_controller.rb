# frozen_string_literal: true
require_dependency "decidim/features/base_controller"

module Decidim
  module Pages
    # This controller is the abstract class from which all other controllers of
    # this engine inherit.
    #
    # Note that it inherits from `Decidim::Features::Basecontroller`, which
    # override its layout and provide all kinds of useful methods.
    class ApplicationController < Decidim::Features::BaseController
      def show
        @page = Page.find_by(feature: current_feature)
      end
    end
  end
end
