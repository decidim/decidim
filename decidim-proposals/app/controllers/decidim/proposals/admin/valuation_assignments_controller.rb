# frozen_string_literal: true

module Decidim
  module Proposals
    module Admin
      class ValuationAssignmentsController < Admin::ApplicationController
        def create
          enforce_permission_to :assign_to_valuator, :proposals

          @form = form(Admin::ValuationAssignmentForm).from_params(params)

          Admin::AssignProposalsToValuator.call(@form) do
            on(:ok) do |_proposal|
              flash[:notice] = I18n.t("valuation_assignments.create.success", scope: "decidim.proposals.admin")
              redirect_to EngineRouter.admin_proxy(current_component).root_path
            end

            on(:invalid) do
              flash.now[:alert] = I18n.t("valuation_assignments.create.invalid", scope: "decidim.proposals.admin")
              redirect_to EngineRouter.admin_proxy(current_component).root_path
            end
          end
        end

        def destroy
          @form = form(Admin::ValuationAssignmentForm).from_params(params)

          enforce_permission_to :unassign_from_valuator, :proposals, valuator: @form.valuator_user

          Admin::UnassignProposalsFromValuator.call(@form) do
            on(:ok) do |_proposal|
              flash[:notice] = I18n.t("valuation_assignments.delete.success", scope: "decidim.proposals.admin")
              redirect_to EngineRouter.admin_proxy(current_component).root_path
            end

            on(:invalid) do
              flash.now[:alert] = I18n.t("valuation_assignments.delete.invalid", scope: "decidim.proposals.admin")
              redirect_to EngineRouter.admin_proxy(current_component).root_path
            end
          end
        end
      end
    end
  end
end
