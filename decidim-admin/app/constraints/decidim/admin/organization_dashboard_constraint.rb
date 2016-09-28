# frozen_string_literal: true
module Decidim
  module Admin
    # A Rails routes constraint to only allow access to an Organization admin to
    # the organization dashboard.
    class OrganizationDashboardConstraint
      # Initializes the contraint.
      #
      # request [Rack::Request]
      def initialize(request)
        @request = request
      end

      # Checks if the user can access the organization dashboard.
      #
      # Returns boolean.
      def matches?
        OrganizationPolicy.new(user, organization).update?
      end

      private

      attr_reader :request

      def organization
        request.env["decidim.current_organization"]
      end

      def user
        return unless request.env["warden"].authenticate!(scope: "user")

        @user ||= request.env["warden"].user("user")
      end
    end
  end
end
