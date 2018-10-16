# frozen_string_literal: true

module Decidim
  # The controller to handle user groups creation
  class GroupsController < Decidim::ApplicationController
    include FormFactory

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
          render action: :show
        end
      end
    end
  end
end
