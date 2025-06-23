# frozen_string_literal: true

module Decidim
  module Elections
    # This controller is the abstract class from which all other controllers of
    # this engine inherit.
    #
    # Note that it inherits from `Decidim::Admin::Components::BaseController`, which
    # override its layout and provide all kinds of useful methods.
    class ApplicationController < Decidim::Components::BaseController
      def elections
        Election.where(component: current_component)
      end
    end
  end
end
