# frozen_string_literal: true

module Decidim
  module Verifications
    module Admin
      class VerificationsController < Decidim::Admin::ApplicationController
        def count
          enforce_permission_to :destroy, :authorization

          @form = form(RevocationsForm).from_params(params)
          if @form.valid?
            count = Decidim::Verifications::Authorizations.new(
              organization: current_organization,
              name: @form.name,
              granted: true,
              impersonated_only: @form.impersonated_only,
              before_date: @form.before_date
            ).query.count
            render json: { count: }
          else
            render json: { error: "invalid" }, status: :unprocessable_content
          end
        end

        def destroy
          enforce_permission_to :destroy, :authorization

          @form = form(RevocationsForm).from_params(params)
          RevokeAuthorizations.call(current_organization, @form) do
            on(:ok) do |count|
              workflow_fullname = Decidim::Verifications.find_workflow_manifest(@form.name)&.fullname || @form.name
              notice_key = @form.impersonated_only? ? "revoked_impersonated" : "revoked"
              flash[:notice] = t("authorization_revocation.#{notice_key}", scope: "decidim.admin.menu", count:, workflow: workflow_fullname)
              redirect_to decidim_admin.authorization_workflows_url
            end
            on(:invalid) do
              flash[:alert] = t("authorization_revocation.destroy_nok", scope: "decidim.admin.menu")
              redirect_to decidim_admin.authorization_workflows_url
            end
          end
        end
      end
    end
  end
end
