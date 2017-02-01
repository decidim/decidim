# frozen_string_literal: true
module Decidim
  # This query filters processes so only promoted ones are returned.
  class PromotedParticipatoryProcesses < Rectify::Query
    def query
      Decidim::ParticipatoryProcess.promoted
    end
  end
end
