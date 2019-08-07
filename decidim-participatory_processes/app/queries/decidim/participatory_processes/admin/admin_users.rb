# frozen_string_literal: true

module Decidim
  module ParticipatoryProcesses
    module Admin
      # A class used to find the admins for a participatory process including
      # organization admins.
      class AdminUsers < Rectify::Query
        # Syntactic sugar to initialize the class and return the queried objects.
        #
        # process - a process that needs to find its process admins
        def self.for(process)
          new(process).query
        end

        # Initializes the class.
        #
        # process - a process that needs to find its process admins
        def initialize(process)
          @process = process
        end

        # Finds organization admins and the users with role admin for the given process.
        #
        # Returns an ActiveRecord::Relation.
        def query
          Decidim::User.where(id: organization_admins).or(process_user_admins)
        end

        private

        attr_reader :process

        def organization_admins
          process.organization.admins
        end

        def process_user_admins
          process_user_admin_ids = Decidim::ParticipatoryProcessUserRole
                                   .where(participatory_process: process, role: :admin)
                                   .pluck(:decidim_user_id)
          Decidim::User.where(id: process_user_admin_ids)
        end
      end
    end
  end
end
