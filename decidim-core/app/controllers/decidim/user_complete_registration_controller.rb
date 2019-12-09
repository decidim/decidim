# frozen_string_literal: true

module Decidim
  # The controller to handle users complete registration
  class UserCompleteRegistrationController < Decidim::ApplicationController
    include FormFactory
    include Decidim::DeviseControllers

    before_action :current_user
    before_action do
      enforce_permission_to :update_profile, :user, current_user: current_user
    end

    def show
      enforce_permission_to :read, :user, current_user: current_user
      @user_complete_registration = form(UserCompleteRegistrationForm).from_model(current_user)
    end

    def update
      enforce_permission_to :update, :user, current_user: current_user
      @user_complete_registration = form(UserCompleteRegistrationForm).from_params(complete_registration_params)

      CreateUserCompleteRegistration.call(current_user, @user_complete_registration) do
        on(:ok) do |email_is_unconfirmed|
          flash[:notice] = if email_is_unconfirmed
                             t("account.update.success_with_email_confirmation", scope: "decidim")
                           else
                             t("account.update.success", scope: "decidim")
                           end

          bypass_sign_in(current_user)
          redirect_to after_sign_up_path_for(current_user)
        end

        on(:invalid) do
          flash[:alert] = t("account.update.error", scope: "decidim")
          render action: :show
        end
      end
    end

    private

    def complete_registration_params
      { avatar: current_user.avatar }.merge(params[:user].to_unsafe_h)
    end

    # The path used after sign up. Defined in Devise
    def after_sign_up_path_for(resource)
      after_sign_in_path_for(resource)
    end

    helper_method :after_sign_up_path_for
  end
end
