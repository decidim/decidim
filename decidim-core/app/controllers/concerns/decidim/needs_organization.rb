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

      def verify_organization
        redirect_to decidim_system.root_path unless current_organization
      end
    end
  end
end
