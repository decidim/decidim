# frozen_string_literal: true

module Decidim
  module Proposals
    module Admin
      # This controller allows admins to answer proposals in a participatory process.
      class ProposalAnswersController < Admin::ApplicationController
        helper_method :proposal

        def edit
          enforce_permission_to :create, :proposal_answer
          @form = form(Admin::ProposalAnswerForm).from_model(proposal)
        end

        def update
          enforce_permission_to :create, :proposal_answer
          @form = form(Admin::ProposalAnswerForm).from_params(params)

          Admin::AnswerProposal.call(@form, proposal) do
            on(:ok) do
              flash[:notice] = I18n.t("proposals.answer.success", scope: "decidim.proposals.admin")
              redirect_to proposals_path
            end

            on(:invalid) do
              flash.now[:alert] = I18n.t("proposals.answer.invalid", scope: "decidim.proposals.admin")
              render action: "edit"
            end
          end
        end

        private

        def proposal
          @proposal ||= Proposal.where(component: current_component).find(params[:id])
        end
      end
    end
  end
end
