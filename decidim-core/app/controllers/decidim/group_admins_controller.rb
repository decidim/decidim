# frozen_string_literal: true

module Decidim
  # The controller to manage user groups admins
  class GroupAdminsController < Decidim::ApplicationController
    include FormFactory
    include UserGroups

    before_action :enforce_user_groups_enabled

    helper_method :user_group

    def index
      enforce_permission_to :manage, :user_group, user_group:
    end

    def demote
      enforce_permission_to :manage, :user_group, user_group: user_group

      DemoteMembership.call(membership, user_group) do
        on(:ok) do
          flash[:notice] = t("group_admins.demote.success", scope: "decidim")

          redirect_back fallback_location: group_manage_users_path(user_group.nickname)
        end

        on(:invalid) do
          flash[:alert] = t("group_admins.demote.error", scope: "decidim")
          redirect_back fallback_location: group_manage_users_path(user_group.nickname)
        end
      end
    end

    private

    def user_group
      @user_group ||= Decidim::UserGroups::ManageableUserGroups.for(current_user).find_by(nickname: params[:group_id])
    end

    def membership
      user_group.memberships.find(params[:id])
    end
  end
end
