# frozen_string_literal: true

module Decidim
  # This query orders processes by importance, prioritizing promoted processes
  # first, and closest to finalization date second.
  class PublishedParticipatoryProcesses < Rectify::Query
    def query
      ParticipatoryProcess.published
    end
  end
end
