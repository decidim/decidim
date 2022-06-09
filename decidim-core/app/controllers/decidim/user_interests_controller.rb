# frozen_string_literal: true

module Decidim
  # The controller to handle the user's interests page.
  class UserInterestsController < Decidim::ApplicationController
    include Decidim::UserProfile

    def show
      enforce_permission_to :read, :user, current_user: current_user
      @user_interests = form(UserInterestsForm).from_model(current_user)
    end

    def update
      enforce_permission_to :update, :user, current_user: current_user
      @user_interests = form(UserInterestsForm).from_params(params)

      UpdateUserInterests.call(current_user, @user_interests) do
        on(:ok) do
          flash.keep[:notice] = t("user_interests.update.success", scope: "decidim")
        end

        on(:invalid) do
          flash.keep[:alert] = t("user_interests.update.error", scope: "decidim")
        end
      end

      redirect_to action: :show
    end
  end
end
