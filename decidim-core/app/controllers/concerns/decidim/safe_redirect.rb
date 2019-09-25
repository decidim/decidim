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
        return params[:redirect_url] unless params[:redirect_url].start_with?("http")
        return if URI.parse(params[:redirect_url]).host != current_organization.host

        params[:redirect_url]
      end
    end
  end
end
