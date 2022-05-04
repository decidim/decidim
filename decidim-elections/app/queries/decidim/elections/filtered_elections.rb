# frozen_string_literal: true

module Decidim
  module Elections
    # A class used to find elections filtered by its state
    class FilteredElections < Decidim::Query
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

      # Finds the Projects scoped to an array of components and filtered
      # by a range of dates.
      def query
        elections = Decidim::Elections::Election.where(component: @components)
        elections = elections.where("created_at >= ?", @start_at) if @start_at.present?
        elections = elections.where("created_at <= ?", @end_at) if @end_at.present?
        elections
      end
    end
  end
end
