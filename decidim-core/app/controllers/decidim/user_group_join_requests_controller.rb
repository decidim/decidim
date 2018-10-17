# frozen_string_literal: true

module Decidim
  # The controller to handle user groups join requests.
  class UserGroupJoinRequestsController < Decidim::ApplicationController
    include FormFactory

    def create
      enforce_permission_to :join, :user_group

      JoinUserGroup.call(current_user, user_group) do
        on(:ok) do |user_group|
          flash[:notice] = t("groups.join.success", scope: "decidim")

          redirect_back fallback_location: profile_members_path(user_group.nickname)
        end

        on(:invalid) do
          flash[:alert] = t("groups.join.error", scope: "decidim")
          redirect_back fallback_location: profile_members_path(user_group.nickname)
        end
      end
    end

    private

    def user_group
      @user_group ||= Decidim::UserGroup.where(organization: current_user.organization).find_by(nickname: params[:group_id])
    end
  end
end
