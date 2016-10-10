# frozen_string_literal: true
module Decidim
  module Admin
    # A policy to define all the authorizations regarding a
    # ParticipatoryProcess, to be used with Pundit.
    class DashboardPolicy < ApplicationPolicy
      # Checks if the user can see the admin dashboard.
      #
      # Returns a Boolean.
      def show?
        user.roles.include?("admin")
      end
    end
  end
end
