# frozen_string_literal: true

module Decidim
  module ParticipatoryProcesses
    module Admin
      # A class used to find the users that can moderate the participatory
      # process.
      class Moderators < Decidim::Query
        # Syntactic sugar to initialize the class and return the queried objects.
        #
        # process - a process that needs to find its moderators
        def self.for(process)
          new(process).query
        end

        # Syntactic sugar to initialize the class and return the queried objects.
        #
        # organization - an organization that needs to find its moderators
        def self.for_organization(organization)
          new(nil, organization).query
        end

        # Initializes the class.
        #
        # process - a process that needs to find its process admins
        # organization - an organization that needs to find its process admins
        def initialize(process, organization = nil)
          @process = process
          @organization = process&.organization || organization
        end

        # Finds organization admins and the users with role admin for the given
        # process.
        #
        # Returns an ActiveRecord::Relation.
        def query
          organization.admins.or(processes_user_admins)
        end

        private

        attr_reader :process, :organization

        def processes_user_admins
          Decidim::User.where(
            id: Decidim::ParticipatoryProcessUserRole.where(participatory_process: processes)
                                                     .where.not(role: :collaborator)
                                                     .select(:decidim_user_id)
          )
        end

        def processes
          if process
            [process]
          else
            Decidim::ParticipatoryProcess.where(organization:)
          end
        end
      end
    end
  end
end
