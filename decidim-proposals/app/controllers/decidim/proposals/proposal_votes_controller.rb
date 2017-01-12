# frozen_string_literal: true

module Decidim
  module Proposals
    # Exposes the proposal vote resource so users can vote proposals.
    class ProposalVotesController < Decidim::Proposals::ApplicationController
      before_action :authenticate_user!

      def create
        @proposal = Proposal.find(params[:proposal_id])

        set_votes_count_classes
        set_vote_button_classes

        @proposal.votes.create!(author: current_user)
      end

      private

      def set_votes_count_classes
        if request_from_list_page?
          @number_class = "card__support__number"
          @label_class = ""
        else
          @number_class = "extra__suport-number"
          @label_class = "extra__suport-text"
        end
      end

      def set_vote_button_classes
        @button_class = if request_from_list_page?
                          "small"
                        else
                          "expanded button--sc"
                        end
      end

      def request_from_list_page?
        URI(request.referer).path == (URI(decidim_proposals.root_path(feature: @proposal.feature)).path.chomp("/") || URI(decidim_proposals.proposals_path(feature: @proposal.feature)).path.chomp("/"))
      end
    end
  end
end
