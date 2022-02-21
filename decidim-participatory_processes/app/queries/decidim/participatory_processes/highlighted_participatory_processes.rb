# frozen_string_literal: true

module Decidim
  module ParticipatoryProcesses
    # This query selects some prioritized processes.
    class HighlightedParticipatoryProcesses < Decidim::Query
      def query
        PrioritizedParticipatoryProcesses.new.query.limit(8)
      end
    end
  end
end
