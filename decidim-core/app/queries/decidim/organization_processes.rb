# frozen_string_literal: true
module Decidim
  # A query object to retrieve all processes from a single organization.
  class OrganizationProcesses < Rectify::Query
    # Initializes the query.
    #
    # organization - The organization that needs its processes fetched.
    def initialize(organization)
      @organization = organization
    end

    # Gets the particiaptory processes form the given organization, prefetching
    # their active step. If no organization is given, it returns an empty
    # ActiveRecord::Relation.
    def query
      return ParticipatoryProcess.none unless organization
      organization.participatory_processes.includes(:active_step)
    end

    private

    attr_reader :organization
  end
end
