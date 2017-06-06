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
        on(:ok) do |email_is_unconfirmed|
          flash.now[:notice] = if email_is_unconfirmed
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

      render action: :show
    end

    def delete
      authorize! :delete, current_user
      @form = form(DeleteAccountForm).from_model(current_user)
    end

    def destroy
      authorize! :delete, current_user
      @form = form(DeleteAccountForm).from_params(params)

      DestroyAccount.call(current_user, @form) do
        on(:ok) do
          sign_out(current_user)
          flash[:notice] = t("account.destroy.success", scope: "decidim")
        end

        on(:invalid) do
          flash[:alert] = t("account.destroy.error", scope: "decidim")
        end
      end

      redirect_to decidim.root_path
    end

    private

    def authorizations
      @authorizations ||= current_user.authorizations
    end
  end
end
