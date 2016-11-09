# frozen_string_literal: true
module Decidim
  module Admin
    # A class used to find the roles of the users that can manage a given
    # participatory process in a process admin role (that is, processs that are
    # not organization admins).
    class ProcessAdminRolesForProcess < Rectify::Query
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

      # Finds the UserRoles of the users that can manage the given process.
      #
      # Returns an ActiveRecord::Relation.
      def query
        ParticipatoryProcessUserRole
          .where(participatory_process: process, role: :admin)
      end

      private

      attr_reader :process
    end
  end
end
