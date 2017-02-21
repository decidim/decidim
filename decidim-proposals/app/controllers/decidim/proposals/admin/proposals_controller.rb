# frozen_string_literal: true
module Decidim
  module Proposals
    module Admin
      # This controller allows admins to manage proposals in a participatory process.
      class ProposalsController < Admin::ApplicationController
        helper Proposals::ApplicationHelper
        helper_method :proposals

        def new
          authorize! :create, Proposal
          @form = form(Admin::ProposalForm).from_params({})
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

        def unreport
          @proposal = Proposal.find(params[:id])
          authorize! :unreport, @proposal

          Admin::UnreportProposal.call(@proposal) do
            on(:ok) do
              flash[:notice] = I18n.t("proposals.unreport.success", scope: "decidim.proposals.admin")
              redirect_to proposals_path(reported: true)
            end

            on(:invalid) do
              flash.now[:alert] = I18n.t("proposals.unreport.invalid", scope: "decidim.proposals.admin")
              redirect_to proposals_path(reported: true)
            end
          end
        end

        private

        def proposals
          @proposals ||= begin
            proposals = Proposal.where(feature: current_feature)
            proposals = proposals.reported if params[:reported]
            proposals
          end
        end
      end
    end
  end
end
