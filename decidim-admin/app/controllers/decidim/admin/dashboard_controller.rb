# frozen_string_literal: true

require_dependency "decidim/admin/application_controller"

module Decidim
  module Admin
    # Controller that shows a simple dashboard.
    #
    class DashboardController < ApplicationController
      authorize_resource :admin_dashboard, class: false
    end
  end
end
