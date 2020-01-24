# frozen_string_literal: true

module Decidim
  module Verifications
    module Admin
      class VerificationsController < ApplicationController
        include NeedsOrganization

        def destroy
# raise
          if params.has_key?(:revocations_before_date) # If before_call config, call Before Date Revoke Authorizations Command
            @form = RevocationsBeforeDateForm.from_params(params[:revocations_before_date])
            if @form.valid?
# raise
              # Revoke filtered authorizations
              RevokeByConditionAuthorizations.call(current_organization, current_user, @form.before_date_picker.strftime('%d/%m/%Y'), @form.impersonated_only) do
                on(:ok) do
                  flash[:notice] = t("authorization_revocation.destroy_ok", scope: "decidim.admin.menu")
# raise
                  redirect_to authorization_workflows_url # TODO no té visibilitat del _path o _url de authorzation !
                  # redirect_to request.referrer
# raise
                end
                on(:invalid) do
                  flash.now[:alert] = t("authorization_revocation.destroy_nok", scope: "decidim.admin.menu")
# raise
                  redirect_to authorization_workflows_url # TODO no té visibilitat del _path o _url de authorzation !
                  # redirect_to request.referrer
                end
              end
# raise
            end
          end
        end

        def destroy_all
# raise
          # If revoke all authorizations, call Revoke All Authorizations Command
          RevokeAllAuthorizations.call(current_organization, current_user) do
            on(:ok) do
              flash[:notice] = t("authorization_revocation.destroy_ok", scope: "decidim.admin.menu")
              redirect_to authorization_workflows_url # TODO no té visibilitat del _path o _url de authorzation !
              # redirect_to request.referrer
            end
            on(:invalid) do
              flash.now[:alert] = t("authorization_revocation.destroy_nok", scope: "decidim.admin.menu")
              redirect_to authorization_workflows_url # TODO no té visibilitat del _path o _url de authorzation !
              # redirect_to request.referrer
            end
          end
# raise
        end
      end
    end
  end
end
