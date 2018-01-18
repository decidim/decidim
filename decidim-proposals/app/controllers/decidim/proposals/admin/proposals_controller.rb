# frozen_string_literal: true

module Decidim
  module Proposals
    module Admin
      # This controller allows admins to manage proposals in a participatory process.
      class ProposalsController < Admin::ApplicationController
        helper Proposals::ApplicationHelper
        helper_method :proposals, :query

        def index
          @categories = current_feature.categories
        end

        def new
          authorize! :create, Proposal
          @form = form(Admin::ProposalForm).from_params(
            attachment: form(AttachmentForm).from_params({})
          )
        end

        def create
          authorize! :create, Proposal
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
          if params[:proposal_ids].present? and params[:category_id].present?
            category = Decidim::Category.find_by_id params[:category_id]
            proposals = Proposal.where(id: params[:proposal_ids])
            proposals.update(category: category)
            flash[:notice] = "Updated category for proposals"
            redirect_to proposals_path
          else
            flash.now[:alert] = "something failed"
            redirect_to edit_category_proposals_path
          end
        end

        private

        def query
          @query ||= Proposal.where(feature: current_feature).ransack(params[:q])
        end

        def proposals
          @proposals ||= query.result.page(params[:page]).per(15)
        end

        def proposal
          @proposal ||= Proposal.where(feature: current_feature).find(params[:id])
        end
      end
    end
  end
end
