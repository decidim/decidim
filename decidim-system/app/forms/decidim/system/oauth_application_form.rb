# frozen_string_literal: true

module Decidim
  module System
    # The form that validates the data to construct a valid OAuthApplication.
    class OAuthApplicationForm < Decidim::Form
      mimic :oauth_application

      attribute :name, String
      attribute :decidim_organization_id, Integer
      attribute :redirect_uri, String

      validates :name, :redirect_uri, :decidim_organization_id, presence: true

      validate :redirect_uri_is_ssl

      private

      def redirect_uri_is_ssl
        return if redirect_uri.blank?

        uri = URI.parse(redirect_uri)

        errors.add(:redirect_uri, :must_be_ssl) if uri.host != "localhost" && uri.scheme != "https"
      end
    end
  end
end
