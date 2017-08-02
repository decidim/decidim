# frozen_string_literal: true

module Decidim
  # This query selects some prioritized processes.
  class HighlightedParticipatoryProcesses < Rectify::Query
    def query
      PrioritizedParticipatoryProcesses.new.query.limit(8)
    end
  end
end
