# frozen_string_literal: true

module Decidim
  # Helper that provides methods to enable or disable omniauth buttons
  module OmniauthHelper
    # Public: returns true if the social provider is enabled
    def social_provider_enabled?(provider)
      Rails.application.secrets.dig(:omniauth, provider.to_sym, :enabled)
    end

    # Public: returns true if any provider is enabled
    def any_social_provider_enabled?
      User.omniauth_providers.any? do |provider|
        social_provider_enabled? provider
      end
    end

    # Public: normalize providers names to they can be used for buttons
    # and icons.
    def normalize_provider_name(provider)
      provider.to_s.split("_").first
    end

    # Public: icon for omniauth buttons
    def oauth_icon(provider)
      name = provider == :developer ? "phone" : normalize_provider_name(provider)

      icon(name)
    end
  end
end
