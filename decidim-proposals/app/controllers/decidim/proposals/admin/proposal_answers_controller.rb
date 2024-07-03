# frozen_string_literal: true

module Decidim
  module Proposals
    module Admin
      # This controller allows admins to answer proposals in a participatory process.
      class ProposalAnswersController < Admin::ApplicationController
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

        def update_multiple_answers
          enforce_permission_to(:create, :proposal_answer)

          if missing_cost_data?(proposals)
            flash[:alert] = t("proposals.answer.missing_cost_data", scope: "decidim.proposals.admin")
            redirect_to EngineRouter.admin_proxy(current_component).root_path

            return
          end

          proposals.each do |proposal|
            enforce_permission_to(:create, :proposal_answer, proposal:)
            ProposalAnswerJob.perform_later(proposal.id, bulk_answer_form(proposal).attributes, current_component)
          end

          flash[:notice] = I18n.t("proposals.answer.success_bulk_update", scope: "decidim.proposals.admin")
          redirect_to EngineRouter.admin_proxy(current_component).root_path
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

        def template
          @template ||= Decidim::Templates::Template.find(params[:template][:template_id])
        end

        def bulk_answer_form(proposal)
          @bulk_answer_form ||= form(ProposalAnswerForm).from_params(prepare_answer_form_params(template, proposal, current_user))
        end

        def prepare_answer_form_params(template, proposal, current_user)
          answer_form_params = {
            answer: translated_attribute(template.description),
            internal_state: Decidim::Proposals::ProposalState.find(template.field_values["proposal_state_id"]).token,
            current_user:
          }

          if current_component.current_settings.answers_with_costs?
            [:cost, :cost_report, :execution_period].each do |field|
              value = proposal.send(field)
              answer_form_params[field] = translated_attribute(value) if value.present?
            end
          end

          answer_form_params
        end

        def missing_cost_data?(proposals)
          proposals.each do |proposal|
            return true if bulk_answer_form(proposal).costs_required? && proposal.cost.blank?
          end
          false
        end
      end
    end
  end
end
