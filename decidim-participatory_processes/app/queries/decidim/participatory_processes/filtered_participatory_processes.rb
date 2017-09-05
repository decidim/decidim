# frozen_string_literal: true

module Decidim
  module ParticipatoryProcesses
    # This query class filters participatory processes given a filter name.
    # It uses the start and end dates to select the correct processes.
    class FilteredParticipatoryProcesses < Rectify::Query
      def initialize(filter = "active")
        @filter = filter
      end

      def query
        processes = Decidim::ParticipatoryProcess.all

        case @filter
        when "past"
          processes.where("decidim_participatory_processes.end_date <= ?", Time.current)
        when "upcoming"
          processes.where("decidim_participatory_processes.start_date > ?", Time.current)
        else
          processes
        end
      end
    end
  end
end
