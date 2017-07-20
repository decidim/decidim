# frozen_string_literal: true

require_dependency "decidim/admin/application_controller"

module Decidim
  module Admin
    # Controller that allows managing managed users at the admin panel.
    #
    class ManagedUsersController < Admin::ApplicationController
      layout "decidim/admin/users"

      def index
        authorize! :index, :managed_users
      end

      def new
        authorize! :new, :managed_users
        @form = form(ManagedUserForm).instance
      end
    end
  end
end
