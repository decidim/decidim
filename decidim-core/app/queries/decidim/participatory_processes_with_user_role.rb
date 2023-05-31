# frozen_string_literal: true

module Decidim
  # A class used to find the ParticipatoryProcesses that the given user has
  # the specific role privilege.
  class ParticipatoryProcessesWithUserRole < Decidim::Query
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

    # Finds the ParticipatoryProcesses that the given user has role privileges.
    # If the special role ':any' is provided it returns all processes where
    # the user has some kind of role privilege.
    #
    # Returns an ActiveRecord::Relation.
    def query
      # Admin users have all role privileges for all organization processes
      return ParticipatoryProcesses::OrganizationParticipatoryProcesses.new(user.organization).query if user.admin?

      ParticipatoryProcess.where(id: process_ids)
    end

    private

    attr_reader :user, :role

    def process_ids
      user_roles = ParticipatoryProcessUserRole.where(user:) if role == :any
      user_roles = ParticipatoryProcessUserRole.where(user:, role:) if role != :any
      user_roles.pluck(:decidim_participatory_process_id)
    end
  end
end
