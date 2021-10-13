# frozen_string_literal: true

require "active_support/concern"

module Decidim
  # This concern groups methods and helpers related to redirecting the user from URL params.
  module SafeRedirect
    extend ActiveSupport::Concern

    included do
      helper_method :redirect_url

      # Sanitizes the redirect url only allowing relative paths or absolute URLs
      # that match the current organization.
      def redirect_url
        return if params[:redirect_url].blank?

        # Parse given URL
        target_uri = URI.parse(params[:redirect_url])

        # Add the organization host to the URL if not present
        target_uri = URI.join("#{request.scheme}://#{current_organization.host}", target_uri) unless target_uri.host

        # Don't allow URLs without host or with a different host than the organization one
        return if target_uri.host != current_organization.host

        # Convert the URI to relative
        target_uri.scheme = target_uri.host = target_uri.port = nil

        # Return the relative URL
        target_uri.to_s
      end
    end
  end
end
