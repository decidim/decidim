# frozen_string_literal: true
require_dependency "decidim/admin/application_controller"

module Decidim
  module Admin
    # Controller that shows a simple dashboard.
    #
    class DashboardController < ApplicationController
      skip_authorization_check only: :show
    end
  end
end
