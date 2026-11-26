# frozen_string_literal: true

module Decidim
  module Verifications
    module Admin
      class VerificationsController < Decidim::Admin::ApplicationController
        def count
          enforce_permission_to :destroy, :authorization

          @form = form(RevocationsForm).from_params(params)
          if @form.valid?
            counts = { total: authorizations_count(impersonated_only: false), impersonated: authorizations_count(impersonated_only: true) }
            count = counts[@form.option.to_sym]
            render json: { counts:, message: confirm_message(count), callout: callout(count), period: period_label }
          else
            render json: { error: "invalid" }, status: :unprocessable_content
          end
        end

        def destroy
          enforce_permission_to :destroy, :authorization

          @form = form(RevocationsForm).from_params(params)
          RevokeAuthorizations.call(current_organization, @form) do
            on(:ok) do |count|
              flash[:notice] = t("decidim.admin.menu.authorization_revocation.revoked.#{@form.option}", count:, workflow: workflow_fullname)
              redirect_to decidim_admin.authorization_workflows_url
            end
            on(:invalid) do
              flash[:alert] = t("authorization_revocation.destroy_nok", scope: "decidim.admin.menu")
              redirect_to decidim_admin.authorization_workflows_url
            end
          end
        end

        private

        def workflow_fullname
          Decidim::Verifications.find_workflow_manifest(@form.name)&.fullname || @form.name
        end

        def authorizations_count(impersonated_only:, before_date: @form.before_date)
          Decidim::Verifications::Authorizations.new(
            organization: current_organization,
            name: @form.name,
            granted: true,
            impersonated_only:,
            before_date:
          ).query.count
        end

        def confirm_message(count)
          t(
            "decidim.admin.menu.authorization_revocation.destroy.confirm_message.#{@form.option}.#{@form.period}_html",
            count:,
            workflow: workflow_fullname,
            date: formatted_date
          )
        end

        def callout(count)
          scope = "decidim.admin.menu.authorization_revocation.callout.#{@form.option}"
          if count.zero? && @form.before_date
            option_total = authorizations_count(impersonated_only: @form.impersonated_only, before_date: nil)
            { level: "warning", message: t("#{scope}.nothing_before_date", count: option_total, date: formatted_date) }
          else
            { level: "info", message: t("#{scope}.#{@form.period}", count:, date: formatted_date) }
          end
        end

        def period_label
          @form.before_date && t("decidim.admin.menu.authorization_revocation.created_before", date: formatted_date)
        end

        def formatted_date
          @form.before_date && l(@form.before_date, format: :decidim_short)
        end
      end
    end
  end
end
