# frozen_string_literal: true

module Decidim
  module Proposals
    module Admin
      # This controller allows admins to manage proposals in a participatory process.
      class ProposalsController < Admin::ApplicationController
        helper Proposals::ApplicationHelper
        helper_method :proposals, :query

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
              flash.now[:notice] = update_proposals_category_response_successful @response
              flash.now[:alert] = update_proposals_category_response_errored @response
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

        def query
          @query ||= Proposal.where(component: current_component).published.ransack(params[:q])
        end

        def proposals
          @proposals ||= query.result.page(params[:page]).per(15)
        end

        def proposal
          @proposal ||= Proposal.where(component: current_component).find(params[:id])
        end

        def update_proposals_category_response_successful(response)
          return if response[:successful].blank?
          I18n.t(
            "proposals.update_category.success",
            category: response[:category_name],
            proposals: response[:successful].to_sentence,
            scope: "decidim.proposals.admin"
          )
        end

        def update_proposals_category_response_errored(response)
          return if response[:errored].blank?
          I18n.t(
            "proposals.update_category.invalid",
            category: response[:category_name],
            proposals: response[:errored].to_sentence,
            scope: "decidim.proposals.admin"
          )
        end
      end
    end
  end
end
