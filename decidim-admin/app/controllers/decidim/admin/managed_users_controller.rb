# frozen_string_literal: true

require_dependency "decidim/admin/application_controller"

module Decidim
  module Admin
    # Controller that allows managing managed users at the admin panel.
    #
    class ManagedUsersController < Admin::ApplicationController
      def index
        authorize! :index, :managed_users
      end

      def new
        authorize! :new, :managed_users
      end
    end
  end
end
