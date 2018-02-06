# frozen_string_literal: true

module Decidim
  module Proposals
    # A class used to find proposals filtered by features and a date range
    class FilteredProposals < Rectify::Query
      # Syntactic sugar to initialize the class and return the queried objects.
      #
      # features - An array of Decidim::Feature
      # start_at - A date to filter resources created after it
      # end_at - A date to filter resources created before it.
      def self.for(features, start_at = nil, end_at = nil)
        new(features, start_at, end_at).query
      end

      # Initializes the class.
      #
      # features - An array of Decidim::Feature
      # start_at - A date to filter resources created after it
      # end_at - A date to filter resources created before it.
      def initialize(features, start_at = nil, end_at = nil)
        @features = features
        @start_at = start_at
        @end_at = end_at
      end

      # Finds the Proposals scoped to an array of features and filtered
      # by a range of dates.
      def query
        proposals = Decidim::Proposals::Proposal.where(feature: @features)
        proposals = proposals.where("created_at >= ?", @start_at) if @start_at.present?
        proposals = proposals.where("created_at <= ?", @end_at) if @end_at.present?
        proposals
      end
    end
  end
end
