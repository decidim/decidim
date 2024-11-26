# frozen_string_literal: true

require "cell/partial"

module Decidim
  module Proposals
    # This cell renders the proposal card for an instance of a Proposal
    # the default size is the Grid Card (:g)
    class ProposalGCell < Decidim::CardGCell
      include Decidim::Proposals::ApplicationHelper
      include Decidim::LayoutHelper

      delegate :state_item, to: :metadata_cell_instance

      def show
        render
      end

      def title
        present(model).title(html_escape: true)
      end

      def metadata_cell
        "decidim/proposals/proposal_metadata"
      end

      def proposal_vote_cell
        "decidim/proposals/proposal_vote"
      end

      def has_actions?
        model.component.current_settings.votes_enabled? && !model.draft? && !model.withdrawn? && !model.rejected?
      end

      def proposal_votes_count
        model.proposal_votes_count || 0
      end

      def metadata_cell_instance
        @metadata_cell_instance ||= cell("decidim/proposals/proposal_metadata", model)
      end

      def resource_image_path
        model.attachments.first&.url
      end

      private

      def classes
        super.merge(metadata: "card__list-metadata")
        super.merge(votes: "card__proposals-votes")
      end
    end
  end
end
