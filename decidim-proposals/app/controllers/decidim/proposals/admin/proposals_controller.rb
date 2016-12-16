# frozen_string_literal: true
module Decidim
  module Proposals
    module Admin
      # This controller allows admins to manage proposals in a participatory process.
      class ProposalsController < Admin::ApplicationController
        helper_method :proposals

        def new
          @form = form(ProposalForm).from_params({}, feature: current_feature)
        end

        def create
          @form = form(ProposalForm).from_params(params, feature: current_feature)

          CreateProposal.call(@form) do
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

        private

        def proposals
          @proposals ||= Proposal.where(feature: current_feature)
        end
      end
    end
  end
end
