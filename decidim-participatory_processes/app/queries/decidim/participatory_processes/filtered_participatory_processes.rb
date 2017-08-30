# frozen_string_literal: true

module Decidim
  module ParticipatoryProcesses
    # This query class filters public processes given an organization in a
    # meaningful prioritized order.
    class FilteredParticipatoryProcesses < Rectify::Query
      def initialize(filter = "active")
        @filter = filter
      end

      def query
        processes = Decidim::ParticipatoryProcess.all

        case @filter
        when "past"
          processes.where("ends_at <= ?", Time.current)
        when "upcoming"
          processes.where("starts_at > ?", Time.current)
        else
          processes
        end
      end
    end
  end
end
