# frozen_string_literal: true
module Decidim
  module Admin
    # A policy to define all the authorizations regarding an Organization, to
    # be used with Pundit.
    class OrganizationPolicy < ApplicationPolicy
      # Checks if the user can update an organization.
      #
      # Returns a Boolean.
      def update?
        user.roles.include?("admin") && user.organization == record
      end
    end
  end
end
