# frozen_string_literal: true

module Decidim
  # Shared validation for browser push subscription endpoints.
  module PushSubscriptionEndpointValidator
    private

    def supported_push_subscription_endpoint?(endpoint)
      return false if endpoint.blank?

      uri = URI.parse(endpoint)
      return false unless uri.is_a?(URI::HTTPS)

      host = uri.host&.downcase
      return false if host.blank?

      allowed_push_subscription_endpoint_patterns.any? { |pattern| pattern.match?(host) }
    rescue URI::InvalidURIError
      false
    end

    # Override this method to customize the browser push endpoint allowlist.
    def allowed_push_subscription_endpoint_patterns
      [
        /\A(?:.*\.)?push\.services\.mozilla\.com\z/,
        /\A(?:.*\.)?fcm\.googleapis\.com\z/,
        /\A(?:.*\.)?android\.googleapis\.com\z/,
        /\A(?:.*\.)?push\.apple\.com\z/,
        /\A(?:.*\.)?opera\.com\z/,
        /\A(?:.*\.)?notify\.windows\.com\z/
      ]
    end
  end
end
