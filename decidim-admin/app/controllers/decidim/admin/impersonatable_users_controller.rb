# frozen_string_literal: true

module Decidim
  module Admin
    # Controller that lists users in order to perform impersonation actions on
    # them
    #
    class ImpersonatableUsersController < Decidim::Admin::ApplicationController
      include Decidim::Admin::Officializations::Filterable

      layout "decidim/admin/users"

      helper_method :new_managed_user

      add_breadcrumb_item_from_menu :admin_user_menu

      def index
        enforce_permission_to :index, :impersonatable_user

        @query = params[:q]
        @state = params[:state]

        @users = Decidim::Admin::UserFilter.for(collection, @query, @state)
                                           .page(params[:page])
                                           .per(15)
      end

      private

      def collection
        @collection ||= current_organization.users.not_deleted.not_blocked.where(admin: false, roles: []).order(created_at: :desc)
      end

      def new_managed_user
        Decidim::User.new(managed: true, admin: false, roles: [])
      end
    end
  end
end
