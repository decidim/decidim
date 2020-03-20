# frozen_string_literal: true

module Decidim
  module Verifications
    module Admin
      class VerificationsController < Decidim::Admin::ApplicationController
        def destroy_before_date
          enforce_permission_to :destroy, :authorization
          return unless params.has_key?(:revocations_before_date)

          form = RevocationsBeforeDateForm.from_params(params[:revocations_before_date])
          RevokeByConditionAuthorizations.call(current_organization, current_user, form) do
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
          enforce_permission_to :destroy, :authorization
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
