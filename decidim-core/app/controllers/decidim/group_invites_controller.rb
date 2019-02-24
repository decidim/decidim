# frozen_string_literal: true

module Decidim
  # The controller to manage user groups invitations
  class GroupInvitesController < Decidim::ApplicationController
    include FormFactory
    include UserGroups

    before_action :enforce_user_groups_enabled

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

    def update
      enforce_permission_to :accept, :user_group_invitations

      AcceptGroupInvitation.call(inviting_user_group, current_user) do
        on(:ok) do
          flash[:notice] = t("group_invites.accept.success", scope: "decidim")
          redirect_to profile_groups_path(current_user.nickname)
        end

        on(:invalid) do
          flash[:alert] = t("group_invites.accept.error", scope: "decidim")
          redirect_to profile_groups_path(current_user.nickname)
        end
      end
    end

    def destroy
      enforce_permission_to :reject, :user_group_invitations

      RejectGroupInvitation.call(inviting_user_group, current_user) do
        on(:ok) do
          flash[:notice] = t("group_invites.reject.success", scope: "decidim")
          redirect_to profile_groups_path(current_user.nickname)
        end

        on(:invalid) do
          flash[:alert] = t("group_invites.reject.error", scope: "decidim")
          redirect_to profile_groups_path(current_user.nickname)
        end
      end
    end

    private

    def user_group
      @user_group ||= Decidim::UserGroups::ManageableUserGroups.for(current_user).find_by(nickname: params[:group_id])
    end

    def inviting_user_group
      @inviting_user_group ||= Decidim::UserGroups::InvitedMemberships.for(current_user).find_by(id: params[:id]).user_group
    end
  end
end
