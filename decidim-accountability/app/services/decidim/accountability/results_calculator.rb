# frozen_string_literal: true

module Decidim
  module Accountability
    # This class handles the calculation of progress for a set of results
    class ResultsCalculator
      # Public: Initializes the service.
      def initialize(component, scope_id, category_id)
        @component = component
        @scope_id = scope_id
        @category_id = category_id
      end

      delegate :count, to: :results

      def progress
        results.average("COALESCE(progress, 0)")
      end

      private

      attr_reader :component, :scope_id, :category_id

      def results
        @results ||= begin
          query = Result.where(
            parent_id: nil,
            component:
          )
          query = query.with_any_scope(scope_id) if scope_id
          query = query.with_any_category(category_id) if category_id

          query
        end
      end
    end
  end
end
