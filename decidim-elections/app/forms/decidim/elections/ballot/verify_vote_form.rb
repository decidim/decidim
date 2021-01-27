# frozen_string_literal: true

module Decidim
  module Elections
    module Ballot
      # This class holds the data to verify a vote.
      class VerifyVoteForm < Decidim::Form
        attribute :vote_identifier, String

        validates :vote_identifier, :election, presence: true

        delegate :id, to: :election, prefix: true

        def election_unique_id
          @election_unique_id ||= Decidim::BulletinBoard::MessageIdentifier.unique_election_id(bulletin_board.authority_slug, election_id)
        end

        # Public: returns the associated election for the vote.
        def election
          @election ||= context.election
        end

        def bulletin_board
          @bulletin_board ||= context[:bulletin_board] || Decidim::Elections.bulletin_board
        end
      end
    end
  end
end
