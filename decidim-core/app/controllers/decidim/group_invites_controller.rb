# frozen_string_literal: true

module Decidim
  # The controller to manage user groups invitations
  class GroupInvitesController < Decidim::ApplicationController
    include FormFactory

    helper_method :user_group

    def index
      enforce_permission_to :manage, :user_group, user_group: user_group
      @form = form(InviteUserToGroupForm).instance
    end

    def create
      enforce_permission_to :manage, :user_group, user_group: user_group
      @form = form(InviteUserToGroupForm).from_params(params)

      InviteUserToGroup.call(@form, user_group) do
        on(:ok) do
          flash[:notice] = t("group_invites.invite.success", scope: "decidim")

          redirect_to profile_path(user_group.nickname)
        end

        on(:invalid) do
          flash[:alert] = t("group_invites.invite.error", scope: "decidim")
          render action: :index
        end
      end
    end

    private

    def user_group
      @user_group ||= Decidim::UserGroups::ManageableUserGroups.for(current_user).find_by(nickname: params[:group_id])
    end
  end
end
