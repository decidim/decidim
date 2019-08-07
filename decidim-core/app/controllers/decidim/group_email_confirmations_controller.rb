# frozen_string_literal: true

module Decidim
  # The controller to manage email confirmations for user groups.
  class GroupEmailConfirmationsController < Decidim::ApplicationController
    include FormFactory
    include UserGroups

    before_action :enforce_user_groups_enabled

    helper_method :user_group

    def create
      enforce_permission_to :manage, :user_group, user_group: user_group
      if user_group.email.blank?
        flash.keep[:alert] = t("decidim.profiles.user.fill_in_email_to_confirm_it")
        redirect_to(edit_group_path(user_group.nickname)) && return
      end

      user_group.send_confirmation_instructions

      flash.keep[:notice] = t("decidim.profiles.user.confirmation_instructions_sent")
      redirect_back(fallback_location: decidim.profile_path(user_group.nickname))
    end

    private

    def user_group
      @user_group ||= Decidim::UserGroups::ManageableUserGroups.for(current_user).find_by(nickname: params[:group_id])
    end
  end
end
