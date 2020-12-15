# frozen_string_literal: true

module Decidim
  # A class used to find the Results that the given user has
  # the specific role privilege.
  class ResultsWithUserRole < Rectify::Query
    # Syntactic sugar to initialize the class and return the queried objects.
    #
    # user - a User that needs to find which processes can manage
    # role - (optional) a Symbol to specify the role privilege
    def self.for(user, role = :any)
      new(user, role).query
    end

    # Initializes the class.
    #
    # user - a User that needs to find which processes can manage
    # role - (optional) a Symbol to specify the role privilege
    def initialize(user, role = :any)
      @user = user
      @role = role
    end

    # Finds the Results that the given user has role privileges.
    # If the special role ':any' is provided it returns all processes where
    # the user has some kind of role privilege.
    #
    # Returns an ActiveRecord::Relation.
    def query
      # Admin users have all role privileges for all organization results
      return Results::OrganizationResults.new(user.organization).query if user.admin?

      Result.where(decidim_component_id: component_ids)
    end

    private

    attr_reader :user, :role

    def component_ids
      user_roles = ResultUserRole.where(user: user) if role == :any
      user_roles = ResultUserRole.where(user: user, role: role) if role != :any
      user_roles.pluck(:decidim_component_id)
    end
  end
end
