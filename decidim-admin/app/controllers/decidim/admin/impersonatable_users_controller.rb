# frozen_string_literal: true

module Decidim
  module Admin
    # Controller that lists users in order to perform impersonation actions on
    # them
    #
    class ImpersonatableUsersController < Decidim::Admin::ApplicationController
      layout "decidim/admin/users"

      def index
        authorize! :index, :impersonatable_users

        @users = collection.page(params[:page]).per(15)
      end

      private

      def collection
        @collection ||= current_organization.users
      end
    end
  end
end
