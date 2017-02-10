# frozen_string_literal: true
module Decidim
  module Admin
    # A class used to find the ParticipatoryProcesses that the given user can
    # manage.
    class ManageableParticipatoryProcessesForUser < Rectify::Query
      # Syntactic sugar to initialize the class and return the queried objects.
      #
      # user - a User that needs to find which processes can manage
      def self.for(user)
        new(user).query
      end

      # Initializes the class.
      #
      # user - a User that needs to find which processes can manage
      def initialize(user)
        @user = user
      end

      # Finds the ParticipatoryProcesses that the given user can manage.
      #
      # Returns an ActiveRecord::Relation.
      def query
        return user.organization.participatory_processes if user.role?(:admin) || user.role?(:collaborator)

        ParticipatoryProcess.where(id: process_ids)
      end

      private

      attr_reader :user

      def process_ids
        ParticipatoryProcessUserRole
          .where(user: user, role: :admin)
          .pluck(:decidim_participatory_process_id)
      end
    end
  end
end
