# frozen_string_literal: true

module Decidim
  module Votings
    module Admin
      # A class used to find trustees by participatory space.
      class BallotStyleByVotingCode < Decidim::Query
        # Syntactic sugar to initialize the class and return the queried objects.
        #
        # voting - the voting of the Ballot Style
        # code - the code of the Ballot Style
        def self.for(voting, code)
          new(voting, code).query
        end

        # Initializes the class.
        def initialize(voting, code)
          @voting = voting
          @code = code
        end

        # Gets the ballot style with the specified code in this voting
        def query
          Decidim::Votings::BallotStyle
            .where(voting: @voting)
            .find_by(code: @code)
        end
      end
    end
  end
end
