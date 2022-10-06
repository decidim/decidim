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
        helper_method :proposals, :query, :form_presenter, :proposal, :proposal_ids
        helper Proposals::Admin::ProposalBulkActionsHelper

        def show
          @notes_form = form(ProposalNoteForm).instance
          @answer_form = form(Admin::ProposalAnswerForm).from_model(proposal)
        end

        def new
          enforce_permission_to :create, :proposal
          @form = form(Decidim::Proposals::Admin::ProposalForm).from_params(
            attachment: form(AttachmentForm).from_params({})
          )
        end

        def create
          enforce_permission_to :create, :proposal
          @form = form(Decidim::Proposals::Admin::ProposalForm).from_params(params)

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

          Admin::UpdateProposalCategory.call(params[:category][:id], proposal_ids) do
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
          end

          respond_to do |format|
            format.js { render :update_attribute, locals: { form_selector: "#js-form-recategorize-projects", attribute_selector: "#category_id" } }
          end
        end

        def publish_answers
          enforce_permission_to :publish_answers, :proposals

          Decidim::Proposals::Admin::PublishAnswers.call(current_component, current_user, proposal_ids) do
            on(:invalid) do
              flash.now[:alert] = t(
                "proposals.publish_answers.select_a_proposal",
                scope: "decidim.proposals.admin"
              )
            end

            on(:ok) do
              flash.now[:notice] = I18n.t("proposals.publish_answers.success", scope: "decidim")
            end
          end

          respond_to do |format|
            format.js
          end
        end

        def update_scope
          enforce_permission_to :update, :proposal_scope

          Admin::UpdateProposalScope.call(params[:scope_id], proposal_ids) do
            on(:invalid_scope) do
              flash.now[:error] = t(
                "proposals.update_scope.select_a_scope",
                scope: "decidim.proposals.admin"
              )
            end

            on(:invalid_proposal_ids) do
              flash.now[:alert] = t(
                "proposals.update_scope.select_a_proposal",
                scope: "decidim.proposals.admin"
              )
            end

            on(:update_proposals_scope) do
              flash.now[:notice] = update_proposals_bulk_response_successful(@response, :scope)
              flash.now[:alert] = update_proposals_bulk_response_errored(@response, :scope)
            end
          end
          respond_to do |format|
            format.js { render :update_attribute, locals: { form_selector: "#js-form-scope-change-projects", attribute_selector: "#scope_id" } }
          end
        end

        def edit
          enforce_permission_to :edit, :proposal, proposal: proposal
          @form = form(Admin::ProposalForm).from_model(proposal)
        end

        def update
          enforce_permission_to :edit, :proposal, proposal: proposal

          @form = form(Admin::ProposalForm).from_params(params)

          Admin::UpdateProposal.call(@form, @proposal) do
            on(:ok) do |_proposal|
              flash[:notice] = t("proposals.update.success", scope: "decidim")
              redirect_to proposals_path
            end

            on(:invalid) do
              flash.now[:alert] = t("proposals.update.error", scope: "decidim")
              render :edit
            end
          end
        end

        private

        def collection
          @collection ||= Proposal.where(component: current_component).not_hidden.published
        end

        def proposals
          @proposals ||= filtered_collection
        end

        def proposal
          @proposal ||= collection.find(params[:id])
        end

        def proposal_ids
          @proposal_ids ||= params[:proposal_ids]
        end

        def update_proposals_bulk_response_successful(response, subject)
          return if response[:successful].blank?

          case subject
          when :category
            t(
              "proposals.update_category.success",
              subject_name: response[:subject_name],
              proposals: response[:successful].to_sentence,
              scope: "decidim.proposals.admin"
            )
          when :scope
            t(
              "proposals.update_scope.success",
              subject_name: response[:subject_name],
              proposals: response[:successful].to_sentence,
              scope: "decidim.proposals.admin"
            )
          end
        end

        def update_proposals_bulk_response_errored(response, subject)
          return if response[:errored].blank?

          case subject
          when :category
            t(
              "proposals.update_category.invalid",
              subject_name: response[:subject_name],
              proposals: response[:errored].to_sentence,
              scope: "decidim.proposals.admin"
            )
          when :scope
            t(
              "proposals.update_scope.invalid",
              subject_name: response[:subject_name],
              proposals: response[:errored].to_sentence,
              scope: "decidim.proposals.admin"
            )
          end
        end

        def form_presenter
          @form_presenter ||= present(@form, presenter_class: Decidim::Proposals::ProposalPresenter)
        end
      end
    end
  end
end
