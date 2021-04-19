# frozen_string_literal: true

module Decidim
  module Elections
    # A class used to find elections finished to close their voting period
    class ElectionsFinishedToEnd < Rectify::Query
      # Syntactic sugar to initialize the class and return the queried objects.
      def self.for
        new.query
      end

      # Finds the Elections that should be closed.
      def query
        Decidim::Elections::Election.bb_vote
                                    .where("end_time <= ?", Time.current)
      end
    end
  end
end
