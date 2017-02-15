# frozen_string_literal: true

module Decidim
  module Proposals
    # Exposes the proposal report resource so users can report proposals.
    class ProposalReportsController < Decidim::Proposals::ApplicationController
      include FormFactory
      before_action :authenticate_user!

      def create
        authorize! :report, proposal

        @form = form(ProposalReportForm).from_params(params)

        ReportProposal.call(@form, proposal, current_user) do
          on(:ok) do
            flash[:notice] = I18n.t("proposal_reports.create.success", scope: "decidim.proposals")
            redirect_to proposal_path(proposal)
          end

          on(:invalid) do
            flash.now[:alert] = I18n.t("proposal_reports.create.error", scope: "decidim.proposals")
            redirect_to proposal_path(proposal)
          end
        end
      end

      private

      def proposal
        @proposal ||= Proposal.where(feature: current_feature).find(params[:proposal_id])
      end
    end
  end
end
