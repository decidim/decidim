# frozen_string_literal: true

module Decidim
  module Votings
    module Voter
      # This class holds the data to register an in person vote.
      class InPersonVoteForm < Decidim::Form
        mimic :in_person_vote

        attribute :voter_id, String
        attribute :voter_token, String
        attribute :voted, Boolean

        validates :polling_station, :election, :voted, presence: true

        delegate :id, to: :election, prefix: true
        delegate :slug, to: :polling_station, prefix: true

        # Public: returns the associated election for the in person vote.
        def election
          @election ||= context.election
        end

        # Public: returns the polling station for the in person vote.
        def polling_station
          @polling_station ||= context.polling_station
        end

        # Public: returns the polling_officer registering the in person vote.
        def polling_officer
          @polling_officer ||= context.polling_officer
        end

        def bulletin_board
          @bulletin_board ||= context.bulletin_board || Decidim::Elections.bulletin_board
        end
      end
    end
  end
end
