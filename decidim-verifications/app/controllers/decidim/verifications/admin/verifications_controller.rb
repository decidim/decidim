# frozen_string_literal: true

module Decidim
  module Verifications
    module Admin
      class VerificationsController < ApplicationController
        include NeedsOrganization

        def destroy
          return unless params.has_key?(:revocations_before_date) # If before_call config, call Before Date Revoke Authorizations Command

          @form = RevocationsBeforeDateForm.from_params(params[:revocations_before_date])
          return unless @form.valid?

          # Revoke filtered authorizations
          RevokeByConditionAuthorizations.call(current_organization, current_user, @form.before_date_picker.strftime("%d/%m/%Y"), @form.impersonated_only) do
            on(:ok) do
              flash[:notice] = t("authorization_revocation.destroy_ok", scope: "decidim.admin.menu")
              redirect_to decidim_admin.authorization_workflows_url
            end
            on(:invalid) do
              flash.now[:alert] = t("authorization_revocation.destroy_nok", scope: "decidim.admin.menu")
              redirect_to decidim_admin.authorization_workflows_url
            end
          end
        end

        def destroy_all
          # If revoke all authorizations, call Revoke All Authorizations Command
          RevokeAllAuthorizations.call(current_organization, current_user) do
            on(:ok) do
              flash[:notice] = t("authorization_revocation.destroy_ok", scope: "decidim.admin.menu")
              redirect_to decidim_admin.authorization_workflows_url
            end
            on(:invalid) do
              flash.now[:alert] = t("authorization_revocation.destroy_nok", scope: "decidim.admin.menu")
              redirect_to decidim_admin.authorization_workflows_url
            end
          end
        end
      end
    end
  end
end
