# frozen_string_literal: true

module Decidim
  module Admin
    # The form that validates the data to construct a valid OAuthApplication.
    class OAuthApplicationForm < Decidim::Form
      mimic :oauth_application

      attribute :name, String
      attribute :organization_name, String
      attribute :organization_url, String
      attribute :organization_logo
      attribute :redirect_uri, String

      validates :name, :redirect_uri, :current_user, :current_organization, :organization_name, :organization_url, :organization_logo, presence: true
      validates :organization_logo,
                file_size: { less_than_or_equal_to: ->(_record) { Decidim.maximum_attachment_size } },
                file_content_type: { allow: ["image/jpeg", "image/png"] }
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
