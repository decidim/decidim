# frozen_string_literal: true

module Decidim
  module Accountability
    # This class handles the calculation of progress for a set of results
    class ResultsCalculator
      # Public: Initializes the service.
      def initialize(component, taxonomy_id)
        @component = component
        @taxonomy_id = taxonomy_id
      end

      delegate :count, to: :results

      def progress
        results.average("COALESCE(progress, 0)")
      end

      private

      attr_reader :component, :taxonomy_id

      def results
        @results ||= begin
          query = Result.where(
            parent_id: nil,
            component:
          )
          query = query.with_taxonomies(taxonomy_id) if taxonomy_id

          query
        end
      end
    end
  end
end
