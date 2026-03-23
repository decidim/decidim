# frozen_string_literal: true

module Decidim
  module Accountability
    # Helpers for calculating results progress and count
    module CalculatorHelper
      def progress_calculator(taxonomy_id)
        ResultsCalculator.new(current_component, taxonomy_id).progress
      end

      def count_calculator(taxonomy_id)
        ResultsCalculator.new(current_component, taxonomy_id).count
      end
    end
  end
end
