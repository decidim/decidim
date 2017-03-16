# frozen_string_literal: true

module Decidim
  module Admin
    # Controller that allows managing user groups at the admin panel.
    #
    class UserGroupsController < ApplicationController
      layout "decidim/admin/users"

      def index
        authorize! :index, UserGroup
        @user_groups = collection.page(params[:page]).per(15)
      end

      def verify
        @user_group = collection.find(params[:id])
        authorize! :verify, @user_group

        @user_group.verify!

        flash[:notice] = I18n.t("user_groups.verify.success", scope: "decidim.admin")
        redirect_to decidim_admin.user_groups_path
      end

      private

      def collection
        UserGroup
          .includes(:memberships)
          .where(decidim_user_group_memberships: { decidim_user_id: current_organization.users })
      end
    end
  end
end
