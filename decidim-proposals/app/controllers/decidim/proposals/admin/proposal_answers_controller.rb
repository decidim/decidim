# frozen_string_literal: true

module Decidim
  module Proposals
    module Admin
      # This controller allows admins to answer proposals in a participatory process.
      class ProposalAnswersController < Admin::ApplicationController
        include ActionView::Helpers::SanitizeHelper
        include Decidim::Proposals::Admin::NeedsInterpolations
        include Decidim::Proposals::Admin::Filterable

        helper_method :proposal

        helper Proposals::ApplicationHelper
        helper Decidim::Proposals::Admin::ProposalsHelper
        helper Decidim::Proposals::Admin::ProposalRankingsHelper
        helper Decidim::Messaging::ConversationHelper

        def edit
          enforce_permission_to(:create, :proposal_answer, proposal:)
          @form = form(Admin::ProposalAnswerForm).from_model(proposal)
        end

        def update
          enforce_permission_to(:create, :proposal_answer, proposal:)
          @notes_form = form(ProposalNoteForm).instance
          @answer_form = form(Admin::ProposalAnswerForm).from_params(params)

          Admin::AnswerProposal.call(@answer_form, proposal) do
            on(:ok) do
              flash[:notice] = I18n.t("proposals.answer.success", scope: "decidim.proposals.admin")
              redirect_to proposals_path
            end

            on(:invalid) do
              flash.keep[:alert] = I18n.t("proposals.answer.invalid", scope: "decidim.proposals.admin")
              render template: "decidim/proposals/admin/proposals/show"
            end
          end
        end

        private

        def skip_manage_component_permission
          true
        end

        def proposal
          @proposal ||= Proposal.where(component: current_component).find(params[:id])
        end

        def proposals
          @proposals ||= Proposal.where(component: current_component).where(id: params[:proposal_ids])
        end

        def collection
          @collection ||= Proposal.where(component: current_component).not_hidden.published
        end

        def template
          return unless Decidim.module_installed?(:templates)

          @template ||= Decidim::Templates::Template.find_by(id: params[:template][:template_id])
        end

        def answer_form(proposal)
          form(ProposalAnswerForm).from_params(answer: populate_interpolations(template&.description, proposal), internal_state: proposal_state&.token)
        end

        def proposal_state
          @proposal_state ||= Decidim::Proposals::ProposalState.find_by(id: template&.field_values&.dig("proposal_state_id"))
        end
      end
    end
  end
end
