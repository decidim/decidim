# frozen_string_literal: true

module Decidim
  module System
    # The form that validates the data to construct a valid OAuthApplication.
    class OAuthApplicationForm < Decidim::Form
      include Decidim::HasUploadValidations

      mimic :oauth_application

      attribute :name, String
      attribute :decidim_organization_id, Integer
      attribute :organization_name, String
      attribute :organization_url, String
      attribute :organization_logo
      attribute :redirect_uri, String

      validates :name, :redirect_uri, :decidim_organization_id, :organization_name, :organization_url, :organization_logo, presence: true
      validates :organization_logo, passthru: { to: Decidim::OAuthApplication }
      validate :redirect_uri_is_ssl

      alias organization current_organization

      private

      def redirect_uri_is_ssl
        return if redirect_uri.blank?

        uri = URI.parse(redirect_uri)

        errors.add(:redirect_uri, :must_be_ssl) if uri.host != "localhost" && uri.scheme != "https"
      end
    end
  end
end
