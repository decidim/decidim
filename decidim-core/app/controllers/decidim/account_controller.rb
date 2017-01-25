# frozen_string_literal: true
require_dependency "decidim/application_controller"

module Decidim
  # The controller to handle the user's account page.
  class AccountController < ApplicationController
    helper_method :authorizations
    include Decidim::UserProfile

    def show
      authorize! :show, current_user
      @account = form(AccountForm).from_model(current_user)
    end

    def update
      authorize! :update, current_user
      @account = form(AccountForm).from_params(params)

      UpdateAccount.call(current_user, @account) do
        on(:ok) do |account|
          flash.now[:notice] = if current_user.unconfirmed_email.present?
                                 t("account.update.success_with_email_confirmation", scope: "decidim")
                               else
                                 t("account.update.success", scope: "decidim")
                               end

          account.remove_avatar = false
          bypass_sign_in(current_user)
        end

        on(:invalid) do
          flash.now[:alert] = t("account.update.error", scope: "decidim")
        end
      end

      render action: :show
    end

    private

    def authorizations
      @authorizations ||= current_user.authorizations
    end
  end
end
