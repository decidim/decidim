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

      # Checks if the user can list a participatory process.
      #
      # Returns a Boolean.
      def index?
        return true if record.empty?

        if record.first.is_a?(Decidim::ParticipatoryProcessStep)
          return user.roles.include?("admin") && user.organization == record.first.participatory_process.organization
        end

        user.roles.include?("admin") && user.organization == record.first.organization
      end

      # Checks if the user can see a participatory process.
      #
      # Returns a Boolean.
      def show?
        if record.is_a?(Decidim::ParticipatoryProcessStep)
          return user.roles.include?("admin") && user.organization == record.participatory_process.organization
        end

        user.roles.include?("admin") && user.organization == record.organization
      end

      # Checks if the user can edit a participatory process.
      #
      # Returns a Boolean.
      def edit?
        if record.is_a?(Decidim::ParticipatoryProcessStep)
          return user.roles.include?("admin") && user.organization == record.participatory_process.organization
        end

        user.roles.include?("admin") && user.organization == record.organization
      end

      # Checks if the user can update a participatory process.
      #
      # Returns a Boolean.
      def update?
        if record.is_a?(Decidim::ParticipatoryProcessStep)
          return user.roles.include?("admin") && user.organization == record.participatory_process.organization
        end

        user.roles.include?("admin") && user.organization == record.organization
      end

      # Checks if the user can destroy a participatory process.
      #
      # Returns a Boolean.
      def destroy?
        if record.is_a?(Decidim::ParticipatoryProcessStep)
          return user.roles.include?("admin") && user.organization == record.participatory_process.organization
        end

        user.roles.include?("admin") && user.organization == record.organization
      end
    end
  end
end
