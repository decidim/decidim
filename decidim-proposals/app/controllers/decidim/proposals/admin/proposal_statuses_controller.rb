# frozen_string_literal: true

module Decidim
  module Proposals
    module Admin
      class ProposalStatesController < Admin::ApplicationController
        include Decidim::Paginable

        helper_method :proposal_statuses, :proposal_state
        def index
          enforce_permission_to :read, :proposal_state
        end

        def new
          enforce_permission_to :create, :proposal_state
          @form = form(Decidim::Proposals::Admin::ProposalStateForm).instance
        end

        def create
          enforce_permission_to :create, :proposal_state

          @form = form(ProposalStateForm).from_params(params)

          CreateProposalState.call(@form) do
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
          enforce_permission_to(:update, :proposal_state, proposal_state:)
          @form = form(Decidim::Proposals::Admin::ProposalStateForm).from_model(proposal_state)
        end

        def update
          enforce_permission_to(:update, :proposal_state, proposal_state:)
          @form = form(ProposalStateForm).from_params(params)

          UpdateProposalState.call(@form, proposal_state) do
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
          enforce_permission_to(:destroy, :proposal_state, proposal_state:)

          DestroyProposalState.call(proposal_state, current_user) do
            on(:ok) do
              flash[:notice] = I18n.t("proposal_statuses.destroy.success", scope: "decidim.proposals.admin")

              redirect_to proposal_statuses_path
            end
          end
        end

        private

        def proposal_state
          @proposal_state ||= proposal_statuses.find(params.expect(:id))
        end

        def proposal_statuses
          @proposal_statuses ||= paginate(ProposalState.where(component: current_component))
        end
      end
    end
  end
end
