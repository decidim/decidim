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

      begin
        UpdateAccount.call(current_user, @account) do
          on(:ok) do |_account, unconfirmed_email|
            flash.now[:notice] = if unconfirmed_email
                                  t("account.update.success_with_email_confirmation", scope: "decidim")
                                else
                                  t("account.update.success", scope: "decidim")
                                end

            bypass_sign_in(current_user)
          end

          on(:invalid) do
            flash.now[:alert] = t("account.update.error", scope: "decidim")
          end
        end
      rescue ActiveRecord::RecordInvalid => msg
        flash.now[:alert] = msg
      end

      render action: :show
    end

    private

    def authorizations
      @authorizations ||= current_user.authorizations
    end
  end
end
