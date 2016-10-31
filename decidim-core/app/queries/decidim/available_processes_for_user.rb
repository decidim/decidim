# frozen_string_literal: true
module Decidim
  # A query object to retrieve available processes for the user organization.
  # Changes the scope based on the user role.
  class AvailableProcessesForUser < Rectify::Query
    # Initializes the query.
    #
    # user - the User that needs the processes checked.
    # organization - the current Organization.
    def initialize(user, organization)
      @user = user
      @organization = organization
    end

    # Returns the processes for the given user and organization. When no
    # organization is given, it returns an empty ActiveRecord::Relation.
    # Otherwise checks the user role and organization and returns all the
    # organization processes if the user is an admin, or its published
    # processes otherwise.
    def query
      return ParticipatoryProcess.none unless organization

      if user && user.role?(:admin) && user.organization == organization
        OrganizationProcesses.new(organization).query
      else
        PublishedProcesses.new(organization).query
      end
    end

    private

    attr_reader :user, :organization
  end
end
