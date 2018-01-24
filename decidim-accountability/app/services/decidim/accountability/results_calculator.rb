# frozen_string_literal: true

module Decidim
  module Accountability
    # This class handles the calculation of progress for a set of results
    class ResultsCalculator
      # Public: Initializes the service.
      def initialize(feature, scope_id, category_id)
        @feature = feature
        @scope_id = scope_id
        @category_id = category_id
      end

      delegate :count, to: :results

      def progress
        results.average(:progress)
      end

      private

      attr_reader :feature, :scope_id, :category_id

      def results
        @results ||= ResultSearch.new(
          feature: feature,
          scope_id: scope_id,
          category_id: category_id
        ).where(parent_id: nil).results
      end
    end
  end
end
