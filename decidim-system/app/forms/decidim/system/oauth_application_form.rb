# frozen_string_literal: true

module Decidim
  module System
    # The form that validates the data to construct a valid OAuthApplication.
    class OAuthApplicationForm < Decidim::Form
      include Decidim::HasUploadValidations

      mimic :oauth_application

      attribute :name, String
      attribute :application_type, String
      attribute :decidim_organization_id, Integer
      attribute :organization_name, String
      attribute :organization_url, String
      attribute :organization_logo
      attribute :redirect_uri, String
      attribute :scopes, Array[String], default: ::Doorkeeper.config.default_scopes.all
      attribute :refresh_tokens_enabled, Boolean, default: false

      validates :name, :redirect_uri, :decidim_organization_id, :organization_name, :organization_url, presence: true
      validates :application_type, inclusion: { in: :application_types }
      validates :organization_url, url: true
      validates :organization_logo, presence: true, unless: :persisted?
      validates :organization_logo, passthru: { to: Decidim::OAuthApplication }
      validates :scopes, inclusion: { in: ::Doorkeeper.config.scopes.all }
      validate :redirect_uri_is_ssl

      def map_model(model)
        self.application_type = model.confidential? ? "confidential" : "public"
      end

      def organization
        current_organization || Decidim::Organization.find_by(id: decidim_organization_id)
      end

      def application_types
        %w(confidential public)
      end

      def confidential?
        application_type == "confidential"
      end

      private

      def redirect_uri_is_ssl
        return if redirect_uri.blank?

        uri = URI.parse(redirect_uri)
        return if local_uri?(uri)

        # We assume confidential clients need to always connect through `https`.
        #
        # For public clients, we display the error only if the scheme is `http`
        # because e.g. iOS application redirect URI may require to use a
        # different scheme.
        errors.add(:redirect_uri, :must_be_ssl) if (confidential? && uri.scheme != "https") || uri.scheme == "http"
      end

      def local_uri?(uri)
        %w(localhost 10.0.2.2).include?(uri.host)
      end
    end
  end
end
