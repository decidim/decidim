# frozen_string_literal: true

require "active_support/concern"

module Decidim
  # Shared behaviour for controllers that need an organization present in order
  # to work. The organization is injected via the CurrentOrganization
  # middleware.
  module NeedsOrganization
    extend ActiveSupport::Concern

    included do
      before_action :verify_organization
      helper_method :current_organization

      # The current organization for the request.
      #
      # Returns an Organization.
      def current_organization
        @current_organization ||= request.env["decidim.current_organization"]
      end

      private

      # Raises a 404 if no organization is present.
      def verify_organization
        raise ActionController::RoutingError, "Not Found" unless current_organization
      end
    end
  end
end
