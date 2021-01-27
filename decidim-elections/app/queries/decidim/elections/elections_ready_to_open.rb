# frozen_string_literal: true

module Decidim
  module Elections
    # A class used to find elections ready and near to start to open their ballot boxes
    class ElectionsReadyToOpen < Rectify::Query
      # Syntactic sugar to initialize the class and return the queried objects.
      def self.for
        new.query
      end

      # Finds the Elections that should be opened.
      def query
        Decidim::Elections::Election.bb_ready
                                    .where("start_time <= ?", minimum_start_time)
      end

      private

      def minimum_start_time
        @minimum_start_time ||= Decidim::Elections.setup_minimum_hours_before_start.hours.from_now
      end
    end
  end
end
