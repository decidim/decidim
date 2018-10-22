# frozen_string_literal: true

module Decidim
  # The controller to manage user groups members
  class GroupMembersController < Decidim::ApplicationController
    include FormFactory

    helper_method :user_group

    def index
      enforce_permission_to :manage, :user_group, user_group: user_group
    end

    private

    def user_group
      @user_group ||= Decidim::UserGroups::ManageableUserGroups.for(current_user).find_by(nickname: params[:group_id])
    end
  end
end
