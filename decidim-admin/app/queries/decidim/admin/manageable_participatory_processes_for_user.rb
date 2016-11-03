# frozen_string_literal: true
module Decidim
  module Admin
    # A class used to find the ParticipatoryProcesses that the given user can
    # manage.
    class ManageableParticipatoryProcessesForUser < Rectify::Query
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
        return user.organization.participatory_processes if user.role?(:admin)

        roles = ParticipatoryProcessUserRole.where(user: user)
        ParticipatoryProcess.where(id: roles.pluck(:decidim_participatory_process_id))
      end

      private

      attr_reader :user
    end
  end
end
