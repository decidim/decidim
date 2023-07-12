# frozen_string_literal: true

module Decidim
  module Pages
    # This controller is the abstract class from which all other controllers of
    # this engine inherit.
    #
    # Note that it inherits from `Decidim::Components::Basecontroller`, which
    # override its layout and provide all kinds of useful methods.
    class ApplicationController < Decidim::Components::BaseController
      redesign_participatory_space_layout

      def show
        @page = Page.find_by(component: current_component)
      end
    end
  end
end
