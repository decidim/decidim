# frozen_string_literal: true

module Decidim
  # This query adds some scopes so the processes are ready to be showed in a
  # public view.
  class HighlightedParticipatoryProcesses < Rectify::Query
    def query
      PrioritizedParticipatoryProcesses.new.query.limit(8)
    end
  end
end
