# frozen_string_literal: true
module Decidim
  module Admin
    # A policy to define all the authorizations regarding a
    # ParticipatoryProcess and its related steps, to be used with Pundit.
    class ParticipatoryProcessPolicy < ApplicationPolicy
      # Checks if the user can see the form for participatory process creation.
      #
      # Returns a Boolean.
      def new?
        user.roles.include?("admin")
      end

      # Checks if the user can create a participatory process.
      #
      # Returns a Boolean.
      def create?
        user.roles.include?("admin")
      end

      # Checks if the user can reorder a participatory process steps.
      #
      # Returns a Boolean.
      def ordering?
        user.roles.include?("admin")
      end

      # Checks if the user can list a participatory process.
      #
      # Returns a Boolean.
      def index?
        return true if record.empty?

        check_admin_and_organization(record.first)
      end

      # Checks if the user can see a participatory process.
      #
      # Returns a Boolean.
      def show?
        check_admin_and_organization
      end

      # Checks if the user can edit a participatory process.
      #
      # Returns a Boolean.
      def edit?
        check_admin_and_organization
      end

      # Checks if the user can update a participatory process.
      #
      # Returns a Boolean.
      def update?
        check_admin_and_organization
      end

      # Checks if the user can destroy a participatory process.
      #
      # Returns a Boolean.
      def destroy?
        check_admin_and_organization
      end

      private

      def check_admin_and_organization(record_to_validate = nil)
        record_to_validate ||= record

        user.roles.include?("admin") && user.organization == record_to_validate.organization
      end
    end
  end
end
