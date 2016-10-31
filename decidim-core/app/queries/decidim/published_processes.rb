# frozen_string_literal: true
module Decidim
  # A query object to retrieve promoted processes.
  class PublishedProcesses < Rectify::Query
    # Initializes the query.
    #
    # organization - the Organization that needs its processes fetched.
    #   Optional.
    def initialize(organization = nil)
      @organization = organization
    end

    # Returns all processes from the organization, if set. Otherwise returns
    # all processes from the database.
    def query
      scope.includes(:active_step).published
    end

    private

    attr_reader :organization

    def scope
      return ParticipatoryProcess.all unless organization

      OrganizationProcesses.new(organization).query
    end
  end
end
