# frozen_string_literal: true
module Decidim
  # This query filters processes so only promoted ones are returned.
  class HighlightedParticipatoryProcesses < Rectify::Query
    def query
      Decidim::ParticipatoryProcess.includes(:active_step).order("promoted DESC, end_date ASC")
    end
  end
end
