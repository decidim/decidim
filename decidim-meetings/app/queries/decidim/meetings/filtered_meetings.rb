# frozen_string_literal: true

module Decidim
  module Meetings
    # A class used to find meetings filtered by components and a date range
    class FilteredMeetings < Rectify::Query
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
        meetings = Decidim::Meetings::Meeting.not_hidden.where(component: @components)
        meetings = meetings.where("created_at >= ?", @start_at) if @start_at.present?
        meetings = meetings.where("created_at <= ?", @end_at) if @end_at.present?
        meetings
      end
    end
  end
end
