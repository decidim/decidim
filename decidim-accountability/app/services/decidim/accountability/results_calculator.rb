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

      def progress
        results.average(:progress)
      end

      def count
        # if there are children return the total number of children results
        # if not return the count of results (they are leafs)
        children = results.sum(:children_count)
        children > 0 ? children : results.count
      end

      private

      attr_reader :feature, :scope_id, :category_id

      def results
        @results ||= ResultSearch.new(feature: feature, scope_id: scope_id, category_id: category_id, parent_id: nil).results
      end
    end
  end
end
