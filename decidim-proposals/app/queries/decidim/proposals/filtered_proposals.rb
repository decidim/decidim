# frozen_string_literal: true

module Decidim
  module Proposals
    # A class used to find proposals filtered by components and a date range
    class FilteredProposals < Decidim::Query
      # Syntactic sugar to initialize the class and return the queried objects.
      #
      # components - An array of Decidim::Component
      # start_at - A date to filter resources created after it
      # end_at - A date to filter resources created before it.
      def self.for(components, start_at = nil, end_at = nil)
        new(components, start_at, end_at).query
      end

      # Initializes the class.
      #
      # components - An array of Decidim::Component
      # start_at - A date to filter resources created after it
      # end_at - A date to filter resources created before it.
      def initialize(components, start_at = nil, end_at = nil)
        @components = components
        @start_at = start_at
        @end_at = end_at
      end

      # Finds the Proposals scoped to an array of components and filtered
      # by a range of dates.
      def query
        proposals = Decidim::Proposals::Proposal.where(component: @components)
        proposals = proposals.where("created_at >= ?", @start_at) if @start_at.present?
        proposals = proposals.where("created_at <= ?", @end_at) if @end_at.present?
        proposals
      end
    end
  end
end
