# frozen_string_literal: true

require "active_support/concern"

module Decidim
  # When included in a controller this concern will wrap any action
  # in the context of the organization configured time zone
  module UseOrganizationTimeZone
    extend ActiveSupport::Concern

    included do
      around_action :use_organization_time_zone
      helper_method :organization_time_zone

      # Executes a block of code in the context of the the organization's time zone
      #
      # &action - a block of code to be wrapped around the time zone
      #
      # Returns nothing.
      def use_organization_time_zone(&)
        Time.use_zone(organization_time_zone, &)
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
