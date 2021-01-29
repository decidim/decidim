# frozen_string_literal: true

module Decidim
  module Elections
    module Voter
      # This class holds the data to cast a vote.
      class EncryptedVoteForm < Decidim::Form
        attribute :encrypted_vote, String
        attribute :encrypted_vote_hash, String

        validates :encrypted_vote, :encrypted_vote_hash, :current_user, :election, presence: true
        validate :hash_is_valid

        delegate :id, to: :election, prefix: true

        def election_unique_id
          @election_unique_id ||= Decidim::BulletinBoard::MessageIdentifier.unique_election_id(bulletin_board.authority_slug, election_id)
        end

        # Public: computes a unique id for the voter/election pair.
        def voter_id
          @voter_id ||= Digest::SHA256.hexdigest([current_user.created_at, current_user.id, election.id, bulletin_board.authority_slug].join("."))
        end

        # Public: returns the associated election for the vote.
        def election
          @election ||= context.election
        end

        def bulletin_board
          @bulletin_board ||= context[:bulletin_board] || Decidim::Elections.bulletin_board
        end

        def current_user
          @current_user ||= context[:current_user]
        end

        private

        # Private: check if the hash sent by the browser is correct.
        def hash_is_valid
          return if encrypted_vote.blank? || encrypted_vote_hash.blank?

          errors.add(:encrypted_vote_hash, :invalid) if Digest::SHA256.hexdigest(encrypted_vote) != encrypted_vote_hash
        end
      end
    end
  end
end
