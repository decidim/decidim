# frozen_string_literal: true

module Decidim
  module ParticipatoryProcesses
    # This query class filters participatory processes given a filter name.
    # It uses the start and end dates to select the correct processes.
    class FilteredParticipatoryProcesses < Decidim::Query
      def initialize(filter = "active")
        @filter = filter
      end

      def query
        processes = Decidim::ParticipatoryProcess.all

        case @filter
        when "all"
          processes
        when "past"
          processes.past
        when "upcoming"
          processes.upcoming
        else
          processes.active
        end
      end
    end
  end
end
