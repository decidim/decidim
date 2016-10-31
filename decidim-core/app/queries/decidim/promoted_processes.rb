# frozen_string_literal: true
module Decidim
  # A query object to retrieve promoted processes.
  class PromotedProcesses < Rectify::Query
    def query
      ParticipatoryProcess.where(promoted: true)
    end
  end
end
