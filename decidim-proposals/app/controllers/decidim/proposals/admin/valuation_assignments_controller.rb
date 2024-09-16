# frozen_string_literal: true

module Decidim
  module Proposals
    module Admin
      class ValuationAssignmentsController < Admin::ApplicationController
        def create
          @form = form(Admin::ValuationAssignmentForm).from_params(params)

          @form.proposals.each do |proposal|
            enforce_permission_to :assign_to_valuator, :proposals, proposal:
          end

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

          @form.valuator_roles.each do |valuator_role|
            enforce_permission_to :unassign_from_valuator, :proposals, valuator: valuator_role.user
          end

          Admin::UnassignProposalsFromValuator.call(@form) do
            on(:ok) do |_proposal|
              flash.keep[:notice] = I18n.t("valuation_assignments.delete.success", scope: "decidim.proposals.admin")
              redirect_back fallback_location: EngineRouter.admin_proxy(current_component).root_path
            end

            on(:invalid) do
              flash.keep[:alert] = I18n.t("valuation_assignments.delete.invalid", scope: "decidim.proposals.admin")
              redirect_back fallback_location: EngineRouter.admin_proxy(current_component).root_path
            end
          end
        end

        private

        def skip_manage_component_permission
          true
        end
      end
    end
  end
end
