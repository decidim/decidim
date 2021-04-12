# frozen_string_literal: true

module Decidim
  module Votings
    class BallotResultForm < Decidim::Form
      attribute :valid_ballots_count, Integer
      attribute :blank_ballots_count, Integer
      attribute :null_ballots_count, Integer

      validates :valid_ballots_count,
                :blank_ballots_count,
                :null_ballots_count,
                presence: true,
                numericality: true

      def map_model(model)
        self.valid_ballots_count = Decidim::Elections::Result.valid_ballots.find_by(election: model[:election], polling_station: model[:polling_station])&.votes_count.to_i
        self.blank_ballots_count = Decidim::Elections::Result.blank_ballots.find_by(election: model[:election], polling_station: model[:polling_station])&.votes_count.to_i
        self.null_ballots_count = Decidim::Elections::Result.null_ballots.find_by(election: model[:election], polling_station: model[:polling_station])&.votes_count.to_i
      end
    end
  end
end
