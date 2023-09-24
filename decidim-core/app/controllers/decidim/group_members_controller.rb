# frozen_string_literal: true

module Decidim
  # The controller to manage user groups members
  class GroupMembersController < Decidim::ApplicationController
    include FormFactory
    include UserGroups

    before_action :enforce_user_groups_enabled

    helper_method :user_group

    # Removes a user from a user group
    def destroy
      enforce_permission_to(:manage, :user_group, user_group:)

      RemoveUserFromGroup.call(membership, user_group) do
        on(:ok) do
          flash[:notice] = t("group_members.remove.success", scope: "decidim")

          redirect_back fallback_location: profile_group_members_path(user_group.nickname)
        end

        on(:invalid) do
          flash[:alert] = t("group_members.remove.error", scope: "decidim")
          redirect_back fallback_location: profile_group_members_path(user_group.nickname)
        end
      end
    end

    def promote
      enforce_permission_to(:manage, :user_group, user_group:)

      PromoteMembership.call(membership, user_group) do
        on(:ok) do
          flash[:notice] = t("group_members.promote.success", scope: "decidim")

          redirect_back fallback_location: profile_group_members_path(user_group.nickname)
        end

        on(:invalid) do
          flash[:alert] = t("group_members.promote.error", scope: "decidim")
          redirect_back fallback_location: profile_group_members_path(user_group.nickname)
        end
      end
    end

    def demote
      enforce_permission_to(:manage, :user_group, user_group:)

      DemoteMembership.call(membership, user_group) do
        on(:ok) do
          flash[:notice] = t("group_admins.demote.success", scope: "decidim")

          redirect_back fallback_location: profile_group_admins_path(user_group.nickname)
        end

        on(:invalid) do
          flash[:alert] = t("group_admins.demote.error", scope: "decidim")
          redirect_back fallback_location: profile_group_admins_path(user_group.nickname)
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
