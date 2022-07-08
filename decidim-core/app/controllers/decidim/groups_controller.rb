# frozen_string_literal: true

module Decidim
  # The controller to handle user groups creation
  class GroupsController < Decidim::ApplicationController
    include FormFactory
    include UserGroups

    before_action :enforce_user_groups_enabled

    def new
      enforce_permission_to :create, :user_group, current_user: current_user
      @form = form(UserGroupForm).instance
    end

    def create
      enforce_permission_to :create, :user_group, current_user: current_user
      @form = form(UserGroupForm).from_params(params)

      CreateUserGroup.call(@form) do
        on(:ok) do |user_group|
          flash[:notice] = t("groups.create.success", scope: "decidim")

          redirect_to profile_path(user_group.nickname)
        end

        on(:invalid) do
          flash[:alert] = t("groups.create.error", scope: "decidim")
          render action: :new
        end
      end
    end

    def edit
      enforce_permission_to :manage, :user_group, current_user: current_user, user_group: user_group
      @form = form(UserGroupForm).from_model(user_group)
    end

    def update
      enforce_permission_to :manage, :user_group, current_user: current_user, user_group: user_group
      @form = form(UserGroupForm).from_params(user_group_params)

      UpdateUserGroup.call(@form, user_group) do
        on(:ok) do |user_group|
          flash[:notice] = t("groups.update.success", scope: "decidim")

          redirect_to profile_path(user_group.nickname)
        end

        on(:invalid) do
          flash[:alert] = t("groups.update.error", scope: "decidim")
          render action: :edit
        end
      end
    end

    def leave
      enforce_permission_to :leave, :user_group, user_group: accepted_user_group

      LeaveUserGroup.call(current_user, accepted_user_group) do
        on(:ok) do
          flash[:notice] = t("groups.leave.success", scope: "decidim")

          redirect_back fallback_location: profile_path(accepted_user_group.nickname)
        end

        on(:last_admin) do
          flash[:alert] = t("groups.leave.last_admin", scope: "decidim")
          redirect_back fallback_location: profile_path(accepted_user_group.nickname)
        end

        on(:invalid) do
          flash[:alert] = t("groups.leave.error", scope: "decidim")
          redirect_back fallback_location: profile_path(accepted_user_group.nickname)
        end
      end
    end

    private

    def accepted_user_group
      @accepted_user_group ||= Decidim::UserGroups::AcceptedUserGroups.for(current_user).find_by(nickname: params[:id])
    end

    def user_group
      @user_group ||= Decidim::UserGroups::ManageableUserGroups.for(current_user).find_by(nickname: params[:id])
    end

    def user_group_params
      params[:group].merge(id: user_group.id)
    end
  end
end
