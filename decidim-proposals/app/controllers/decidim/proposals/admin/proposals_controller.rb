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
          authorize! :update, Proposal
          if params[:proposal_ids].present? && params[:category_id].present?
            category = Decidim::Category.find_by id: params[:category_id]
            updated = { oks: [], invalids: [] }

            Proposal.where(id: params[:proposal_ids]).find_each do |proposal|
              Admin::UpdateProposal.call(category, proposal) do
                on(:ok) { updated[:oks] << proposal.title }

                on(:invalid) { updated[:invalids] << proposal.title }
              end
            end

            if updated[:oks].present?
              flash[:notice] = I18n.t(
                "proposals.update_category.success",
                proposals: updated[:oks].to_sentence,
                scope: "decidim.proposals.admin"
              )
            end

            if updated[:invalids].present?
              flash[:alert] = I18n.t(
                "proposals.update_category.invalid",
                proposals: updated[:invalids].to_sentence,
                scope: "decidim.proposals.admin"
              )
            end
            redirect_to proposals_path
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
