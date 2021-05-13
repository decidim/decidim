# frozen_string_literal: true

module Decidim
  module Elections
    module Voter
      # This class holds the data to cast a vote.
      class VoteForm < Decidim::Form
        mimic :vote

        attribute :encrypted_data, String
        attribute :encrypted_data_hash, String
        attribute :voter_id, String
        attribute :voter_token, String

        validates :encrypted_data, :encrypted_data_hash, :election, presence: true
        validate :hash_is_valid

        delegate :id, to: :election, prefix: true

        # Public: returns the associated election for the vote.
        def election
          @election ||= context.election
        end

        # Public: returns the user for the vote.
        def user
          @user ||= context.user
        end

        # Public: returns the email for the voter.
        def email
          @email ||= context.email
        end

        def bulletin_board
          @bulletin_board ||= context.bulletin_board || Decidim::Elections.bulletin_board
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
