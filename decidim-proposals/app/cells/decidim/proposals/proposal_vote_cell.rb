# frozen_string_literal: true

module Decidim
  # This cell is used to display votes inside a card
  module Proposals
    class ProposalVoteCell < Decidim::ViewModel
      include Decidim::DateRangeHelper
      include Cell::ViewModel::Partial
      include Decidim::ViewHooksHelper

      alias resource model

      def show
        return if @items.blank?

        render
      end

      def initialize(*)
        super

        @items ||= []
        @items << votes_count_item
      end

      private

      def from_proposals_list
        true
      end

      def votes_count_item
        return unless resource.respond_to?(:proposal_votes_count)

        {
          text: resource.proposal_votes_count,
          icon: resource_type_icon_key(:like),
          data_attributes: { votes_count: "" }
        }
      end
    end
  end
end
