# frozen_string_literal: true

require "active_support/concern"

module Decidim
  # Common logic to switch between locales.
  module UseOrganizationTimeZone
    extend ActiveSupport::Concern

    included do
      around_action :use_time_zone
      helper_method :current_time_zone

      private

      # Sets the time zone used to user in the controller
      # Returns nothing.
      def use_time_zone(&action)
        Time.use_zone(current_time_zone, &action)
      end

      # The current time zone from the organization. Available as a helper for the views.
      #
      # Returns a String.
      def current_time_zone
        @current_time_zone ||= current_organization.time_zone
      end
    end
  end
end
