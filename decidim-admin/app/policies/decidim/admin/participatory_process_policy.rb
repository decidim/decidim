# frozen_string_literal: true
module Decidim
  module Admin
    # A policy to define all the authorizations regarding a
    # ParticipatoryProcess, to be used with Pundit.
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

      # Checks if the user can list a participatory process.
      #
      # Returns a Boolean.
      def index?
        user.roles.include?("admin") && user.organization == record.first.organization
      end

      # Checks if the user can see a participatory process.
      #
      # Returns a Boolean.
      def show?
        user.roles.include?("admin") && user.organization == record.organization
      end

      # Checks if the user can edit a participatory process.
      #
      # Returns a Boolean.
      def edit?
        user.roles.include?("admin") && user.organization == record.organization
      end

      # Checks if the user can update a participatory process.
      #
      # Returns a Boolean.
      def update?
        user.roles.include?("admin") && user.organization == record.organization
      end

      # Checks if the user can destroy a participatory process.
      #
      # Returns a Boolean.
      def destroy?
        user.roles.include?("admin") && user.organization == record.organization
      end
    end
  end
end
