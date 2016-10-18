# frozen_string_literal: true
require_dependency "decidim/admin/application_controller"

module Decidim
  module Admin
    # Controller that shows a simple dashboard.
    #
    class DashboardController < ApplicationController
      def show
        authorize :dashboard
      end

      private

      def policy_class(_record)
        Decidim::Admin::DashboardPolicy
      end
    end
  end
end
