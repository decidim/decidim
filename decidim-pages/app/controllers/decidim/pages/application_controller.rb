# frozen_string_literal: true
require "decidim/components/base_controller"

module Decidim
  module Pages
    class ApplicationController < Decidim::Components::BaseController
      def show
        @page = Page.find_by(component: current_component)
      end
    end
  end
end
