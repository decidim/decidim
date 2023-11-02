# frozen_string_literal: true

module Decidim
  module Proposals
    module Admin
      class ProposalStatesController < Admin::ApplicationController
        include Decidim::Admin::Paginable

        helper_method :proposal_states, :proposal_state
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

          CreateProposalState.call(@form, current_component) do
            on(:ok) do
              flash[:notice] = I18n.t("proposal_states.create.success", scope: "decidim.proposals.admin")
              redirect_to proposal_states_path
            end

            on(:invalid) do
              flash.keep[:alert] = I18n.t("proposal_states.create.error", scope: "decidim.proposals.admin")

              render action: :new
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
              flash[:notice] = I18n.t("proposal_states.update.success", scope: "decidim.proposals.admin")

              redirect_to proposal_states_path
            end

            on(:invalid) do
              flash.now[:alert] = I18n.t("proposal_states.update.error", scope: "decidim.proposals.admin")

              render action: :edit
            end
          end
        end

        def destroy
          enforce_permission_to(:destroy, :proposal_state, proposal_state:)

          DestroyProposalState.call(proposal_state, current_user) do
            on(:ok) do
              flash[:notice] = I18n.t("proposal_states.destroy.success", scope: "decidim.proposals.admin")

              redirect_to proposal_states_path
            end
          end
        end

        private

        def proposal_state
          @proposal_state ||= proposal_states.find(params[:id])
        end

        def proposal_states
          @proposal_states ||= paginate(ProposalState.where(component: current_component))
        end
      end
    end
  end
end
