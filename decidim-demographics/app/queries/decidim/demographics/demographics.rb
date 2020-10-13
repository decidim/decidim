# frozen_string_literal: true

module Decidim
  module Demographics
    class DemographicData < Rectify::Query
      # Syntactic sugar to initialize the class and return the queried objects.

      def query
        "DemographicData".query
      end
    end
  end
end
