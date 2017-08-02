# frozen_string_literal: true

module Decidim
  # This query filters published processes only.
  class PublishedParticipatoryProcesses < Rectify::Query
    def query
      ParticipatoryProcess.published
    end
  end
end
