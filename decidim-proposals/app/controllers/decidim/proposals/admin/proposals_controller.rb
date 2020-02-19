# frozen_string_literal: true

module Decidim
  module Proposals
    module Admin
      # This controller allows admins to manage proposals in a participatory process.
      class ProposalsController < Admin::ApplicationController
        include Decidim::ApplicationHelper
        include Decidim::Proposals::Admin::Filterable

        helper Proposals::ApplicationHelper
        helper Decidim::Proposals::Admin::ProposalRankingsHelper
        helper Decidim::Messaging::ConversationHelper
        helper Proposals::Admin::ProposalBulkActionsHelper
        helper_method :proposals, :query, :form_presenter, :proposal

        def show
          @notes_form = form(ProposalNoteForm).instance
          @answer_form = form(Admin::ProposalAnswerForm).from_model(proposal)
        end

        def new
          enforce_permission_to :create, :proposal
          @form = form(Admin::ProposalForm).from_params(
            attachment: form(AttachmentForm).from_params({})
          )
        end

        def create
          enforce_permission_to :create, :proposal
          @form = form(Admin::ProposalForm).from_params(params)

          Admin::CreateProposal.call(@form) do
            on(:ok) do
              flash[:notice] = I18n.t("proposals.create.success", scope: "decidim.proposals.admin")
              redirect_to proposals_path
            end

            on(:invalid) do
              flash.now[:alert] = I18n.t("proposals.create.invalid", scope: "decidim.proposals.admin")
              render action: "new"
            end
          end
        end

        def update_category
          enforce_permission_to :update, :proposal_category
          @proposal_ids = params[:proposal_ids]

          Admin::UpdateProposalCategory.call(params[:category][:id], params[:proposal_ids]) do
            on(:invalid_category) do
              flash.now[:error] = I18n.t(
                "proposals.update_category.select_a_category",
                scope: "decidim.proposals.admin"
              )
            end

            on(:invalid_proposal_ids) do
              flash.now[:alert] = I18n.t(
                "proposals.update_category.select_a_proposal",
                scope: "decidim.proposals.admin"
              )
            end

            on(:update_proposals_category) do
              flash.now[:notice] = update_proposals_bulk_response_successful(@response, :category)
              flash.now[:alert] = update_proposals_bulk_response_errored(@response, :category)
            end
            respond_to do |format|
              format.js
            end
          end
        end

        def update_scope
          enforce_permission_to :update, :proposal_scope
          @proposal_ids = params[:proposal_ids]

          Admin::UpdateProposalScope.call(params[:category][:id], params[:proposal_ids]) do
            on(:invalid_scope) do
              flash.now[:error] = I18n.t(
                "proposals.update_scope.select_a_scope",
                scope: "decidim.proposals.admin"
              )
            end

            on(:invalid_proposal_ids) do
              flash.now[:alert] = I18n.t(
                "proposals.update_scope.select_a_proposal",
                scope: "decidim.proposals.admin"
              )
            end

            on(:update_proposals_scope) do
              flash.now[:notice] = update_proposals_bulk_response_successful(@response, :scope)
              flash.now[:alert] = update_proposals_bulk_response_errored(@response, :scope)
            end

            respond_to do |format|
              format.js
            end
          end
        end

        def edit
          enforce_permission_to :edit, :proposal, proposal: proposal
          @form = form(Admin::ProposalForm).from_model(proposal)
          @form.attachment = form(AttachmentForm).from_params({})
        end

        def update
          enforce_permission_to :edit, :proposal, proposal: proposal

          @form = form(Admin::ProposalForm).from_params(params)
          Admin::UpdateProposal.call(@form, @proposal) do
            on(:ok) do |_proposal|
              flash[:notice] = I18n.t("proposals.update.success", scope: "decidim")
              redirect_to proposals_path
            end

            on(:invalid) do
              flash.now[:alert] = I18n.t("proposals.update.error", scope: "decidim")
              render :edit
            end
          end
        end

        private

        def collection
          @collection ||= Proposal.where(component: current_component).published
        end

        def proposals
          @proposals ||= filtered_collection
        end

        def proposal
          @proposal ||= collection.find(params[:id])
        end

        def update_proposals_bulk_response_successful(response, subject)
          return if response[:successful].blank?

          I18n.t(
            "proposals.update_#{subject}.success",
            "#{subject}": response[:"#{subject}_name"],
            proposals: response[:successful].to_sentence,
            scope: "decidim.proposals.admin"
          )
        end

        def update_proposals_bulk_response_errored(response, subject)
          return if response[:errored].blank?

          I18n.t(
            "proposals.update_#{subject}.invalid",
            "#{subject}": response[:"#{subject}_name"],
            proposals: response[:errored].to_sentence,
            scope: "decidim.proposals.admin"
          )
        end

        def form_presenter
          @form_presenter ||= present(@form, presenter_class: Decidim::Proposals::ProposalPresenter)
        end
      end
    end
  end
end
