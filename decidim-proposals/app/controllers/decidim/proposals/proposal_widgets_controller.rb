# frozen_string_literal: true

module Decidim
  module Proposals
    class ProposalWidgetsController < Decidim::WidgetsController
      helper_method :model

      private

      def model
        @model ||= Proposal.where(feature: params[:feature_id]).find(params[:proposal_id])
      end
    end
  end
end
