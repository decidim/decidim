# frozen_string_literal: true
module Decidim
  # A query object to retrieve promoted processes.
  class PromotedProcesses < Rectify::Query
    # Returns all promoted processes. This is intended to be merged with
    # another query that sets the basic scope, for example
    # `OrganizationProcesses`.
    def query
      ParticipatoryProcess.where(promoted: true)
    end
  end
end
