# frozen_string_literal: true

module Decidim
  module Elections
    module Voter
      # This class holds the data to cast a vote.
      class VoteForm < Decidim::Form
        mimic :vote

        attribute :encrypted_data, String
        attribute :encrypted_data_hash, String

        validates :encrypted_data, :encrypted_data_hash, :current_user, :election, presence: true
        validate :hash_is_valid

        delegate :id, to: :election, prefix: true

        # Public: computes a unique id for the voter/election pair.
        def voter_id
          @voter_id ||= Digest::SHA256.hexdigest([current_user.created_at, current_user.id, election.id, bulletin_board.authority_name.parameterize].join("."))
        end

        # Public: returns the associated election for the vote.
        def election
          @election ||= context.election
        end

        def bulletin_board
          @bulletin_board ||= context[:bulletin_board] || Decidim::Elections.bulletin_board
        end

        def current_user
          @current_user ||= context.current_user
        end

        private

        # Private: check if the hash sent by the browser is correct.
        def hash_is_valid
          return if encrypted_data.blank? || encrypted_data_hash.blank?

          errors.add(:encrypted_data_hash, :invalid) if Digest::SHA256.hexdigest(encrypted_data) != encrypted_data_hash
        end
      end
    end
  end
end
