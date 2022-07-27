# frozen_string_literal: true

module Decidim
  # The controller to handle user groups join requests.
  class UserGroupJoinRequestsController < Decidim::ApplicationController
    include FormFactory
    include UserGroups

    before_action :enforce_user_groups_enabled

    def create
      enforce_permission_to :join, :user_group

      JoinUserGroup.call(current_user, user_group) do
        on(:ok) do
          flash[:notice] = t("groups.join.success", scope: "decidim")

          redirect_back fallback_location: profile_members_path(user_group.nickname)
        end

        on(:invalid) do
          flash[:alert] = t("groups.join.error", scope: "decidim")
          redirect_back fallback_location: profile_members_path(user_group.nickname)
        end
      end
    end

    def update
      enforce_permission_to :manage, :user_group, user_group: user_group

      AcceptUserGroupJoinRequest.call(membership) do
        on(:ok) do
          flash[:notice] = t("group_members.accept.success", scope: "decidim")

          redirect_back fallback_location: group_manage_users_path(user_group.nickname)
        end

        on(:invalid) do
          flash[:alert] = t("group_members.accept.error", scope: "decidim")
          redirect_back fallback_location: group_manage_users_path(user_group.nickname)
        end
      end
    end

    def destroy
      enforce_permission_to :manage, :user_group, user_group: user_group

      RejectUserGroupJoinRequest.call(membership) do
        on(:ok) do
          flash[:notice] = t("group_members.reject.success", scope: "decidim")

          redirect_back fallback_location: group_manage_users_path(user_group.nickname)
        end

        on(:invalid) do
          flash[:alert] = t("group_members.reject.error", scope: "decidim")
          redirect_back fallback_location: group_manage_users_path(user_group.nickname)
        end
      end
    end

    private

    def user_group
      @user_group ||= Decidim::UserGroup.where(organization: current_user.organization).find_by(nickname: params[:group_id])
    end

    def membership
      @membership ||= Decidim::UserGroupMembership.where(user_group:).find(params[:id])
    end
  end
end
