# frozen_string_literal: true

module Decidim
  # The controller to handle the user's account page.
  class AccountController < Decidim::ApplicationController
    include Decidim::UserProfile

    def show
      enforce_permission_to :show, :user, current_user: current_user
      @account = form(AccountForm).from_model(current_user)
    end

    def update
      enforce_permission_to :update, :user, current_user: current_user
      @account = form(AccountForm).from_params(account_params)

      UpdateAccount.call(current_user, @account) do
        on(:ok) do |email_is_unconfirmed|
          flash[:notice] = if email_is_unconfirmed
                             t("account.update.success_with_email_confirmation", scope: "decidim")
                           else
                             t("account.update.success", scope: "decidim")
                           end

          bypass_sign_in(current_user)
          redirect_to account_path(locale: current_user.reload.locale)
        end

        on(:invalid) do
          flash[:alert] = t("account.update.error", scope: "decidim")
          render action: :show
        end
      end
    end

    def delete
      enforce_permission_to :delete, :user, current_user: current_user
      @form = form(DeleteAccountForm).from_model(current_user)
    end

    def destroy
      enforce_permission_to :delete, :user, current_user: current_user
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

    def resend_confirmation_instructions
      enforce_permission_to :update, :user, current_user: current_user

      ResendConfirmationInstructions.call(current_user) do
        on(:ok) do
          respond_to do |format|
            format.json do
              render json: { message: "success", unconfirmed_email: current_user.unconfirmed_email }
            end
          end
        end

        on(:invalid) do
          respond_to do |format|
            format.json do
              render json: { message: "error" }
            end
          end
        end
      end
    end

    def cancel_email_change
      enforce_permission_to :update, :user, current_user: current_user

      if current_user.unconfirmed_email
        current_user.update(unconfirmed_email: nil)

        respond_to do |format|
          format.json do
            render json: { message: "success" }
          end
        end
      else
        respond_to do |format|
          format.json do
            render json: { message: "error" }
          end
        end
      end
    end

    private

    def account_params
      params[:user].to_unsafe_h
    end
  end
end
