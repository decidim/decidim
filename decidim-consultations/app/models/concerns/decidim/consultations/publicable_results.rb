# frozen_string_literal: true

require "active_support/concern"

module Decidim
  module Consultations
    # This concern contains the logic related to results publication and promotion.
    module PublicableResults
      extend ActiveSupport::Concern

      class_methods do
        # Public: Scope to return only records with its results published.
        #
        # Returns an ActiveRecord::Relation.
        def results_published
          where.not(results_published_at: nil)
        end

        # Public: Scope to return only records with its results unpublished.
        #
        # Returns an ActiveRecord::Relation.
        def results_unpublished
          where(results_published_at: nil)
        end
      end

      # Public: Checks whether the record has its results published or not.
      #
      # Returns true if published, false otherwise.
      def results_published?
        results_published_at.present?
      end

      #
      # Public: Publishes the results of the given component
      #
      # Returns true if the record was properly saved, false otherwise.
      def publish_results!
        update!(results_published_at: Time.current)
      end

      #
      # Public: Unpublishes the results
      #
      # Returns true if the record was properly saved, false otherwise.
      def unpublish_results!
        update!(results_published_at: nil)
      end
    end
  end
end
