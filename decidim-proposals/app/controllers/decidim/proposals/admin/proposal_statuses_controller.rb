# frozen_string_literal: true

module Decidim
  module Proposals
    module Admin
      class ProposalStatusesController < Admin::ApplicationController
        include Decidim::Paginable

        helper_method :proposal_statuses, :proposal_status
        def index
          enforce_permission_to :read, :proposal_status
        end

        def new
          enforce_permission_to :create, :proposal_status
          @form = form(Decidim::Proposals::Admin::ProposalStatusForm).instance
        end

        def create
          enforce_permission_to :create, :proposal_status

          @form = form(ProposalStatusForm).from_params(params)

          CreateProposalStatus.call(@form) do
            on(:ok) do
              flash[:notice] = I18n.t("proposal_statuses.create.success", scope: "decidim.proposals.admin")
              redirect_to proposal_statuses_path
            end

            on(:invalid) do
              flash.keep[:alert] = I18n.t("proposal_statuses.create.error", scope: "decidim.proposals.admin")

              render action: :new, status: :unprocessable_content
            end
          end
        end

        def edit
          enforce_permission_to(:update, :proposal_status, proposal_status:)
          @form = form(Decidim::Proposals::Admin::ProposalStatusForm).from_model(proposal_status)
        end

        def update
          enforce_permission_to(:update, :proposal_status, proposal_status:)
          @form = form(ProposalStatusForm).from_params(params)

          UpdateProposalStatus.call(@form, proposal_status) do
            on(:ok) do
              flash[:notice] = I18n.t("proposal_statuses.update.success", scope: "decidim.proposals.admin")

              redirect_to proposal_statuses_path
            end

            on(:invalid) do
              flash.now[:alert] = I18n.t("proposal_statuses.update.error", scope: "decidim.proposals.admin")

              render action: :edit, status: :unprocessable_content
            end
          end
        end

        def destroy
          enforce_permission_to(:destroy, :proposal_status, proposal_status:)

          DestroyProposalStatus.call(proposal_status, current_user) do
            on(:ok) do
              flash[:notice] = I18n.t("proposal_statuses.destroy.success", scope: "decidim.proposals.admin")

              redirect_to proposal_statuses_path
            end
          end
        end

        private

        def proposal_status
          @proposal_status ||= proposal_statuses.find(params.expect(:id))
        end

        def proposal_statuses
          @proposal_statuses ||= paginate(ProposalStatus.where(component: current_component))
        end
      end
    end
  end
end
