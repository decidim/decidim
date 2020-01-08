# frozen_string_literal: true

require "active_support/concern"

module Decidim
  # Common logic to switch between locales.
  module UseOrganizationTimeZone
    extend ActiveSupport::Concern

    included do
      around_action :use_organization_time_zone
      helper_method :organization_time_zone

      # Sets the time zone used to user in the controller
      # Returns nothing.
      def use_organization_time_zone(&action)
        Time.use_zone(organization_time_zone, &action)
      end

      # The current time zone from the organization. Available as a helper for the views.
      #
      # Returns a String.
      def organization_time_zone
        @organization_time_zone ||= current_organization.time_zone
      end
    end
  end
end
