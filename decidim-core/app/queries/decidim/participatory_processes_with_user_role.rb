# frozen_string_literal: true

module Decidim
  # A class used to find the ParticipatoryProcesses that the given user has
  # the specific role privilege.
  class ParticipatoryProcessesWithUserRole < Rectify::Query
    # Syntactic sugar to initialize the class and return the queried objects.
    #
    # user - a User that needs to find which processes can manage
    # role - a Symbol to specify the role privilege
    def self.for(user, role)
      new(user, role).query
    end

    # Initializes the class.
    #
    # user - a User that needs to find which processes can manage
    # role - a Symbol to specify the role privilege
    def initialize(user, role)
      @user = user
      @role = role
    end

    # Finds the ParticipatoryProcesses that the given user has role privileges.
    #
    # Returns an ActiveRecord::Relation.
    def query
      # Admin users have all role privileges for all organization processes
      return user.organization.participatory_processes if user.admin?

      ParticipatoryProcess.where(id: process_ids)
    end

    private

    attr_reader :user, :role

    def process_ids
      ParticipatoryProcessUserRole
        .where(user: user, role: role)
        .pluck(:decidim_participatory_process_id)
    end
  end
end
