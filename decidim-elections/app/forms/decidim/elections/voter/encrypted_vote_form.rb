# frozen_string_literal: true

module Decidim
  module Elections
    module Voter
      # This class holds the data to cast a vote.
      class EncryptedVoteForm < Decidim::Form
        attribute :encrypted_vote, String
        attribute :encrypted_vote_hash, String

        validates :encrypted_vote, :encrypted_vote_hash, :user, :election, presence: true
        validate :hash_is_valid

        # Public: returns the necessary data from the election.
        def election_data
          @election_data ||= { election_id: "#{bulletin_board_client.authority_slug}.#{election.id}" }
        end

        # Public: returns the necessary data from the voter.
        def voter_data
          @voter_data ||= { voter_id: voter_id }
        end

        # Public: returns the associated election for the vote.
        def election
          @election ||= context.election
        end

        # Public: computes a unique id for the voter/election pair.
        def voter_id
          @voter_id ||= Digest::SHA256.hexdigest([user.created_at, user.id, election.id, bulletin_board_client.authority_slug].join("."))
        end

        private

        def bulletin_board_client
          @bulletin_board_client ||= context.bulletin_board_client
        end

        def user
          @user ||= context.user
        end

        # Private: check if the hash sent by the browser is correct.
        def hash_is_valid
          return if encrypted_vote.blank? || encrypted_vote_hash.blank?

          errors.add(:encrypted_vote_hash, :invalid) if Digest::SHA256.hexdigest(encrypted_vote) != encrypted_vote_hash
        end
      end
    end
  end
end
