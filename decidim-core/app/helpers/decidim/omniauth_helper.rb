# frozen_string_literal: true
module Decidim
  # Helper that provides methods to enable or disable omniauth buttons
  module OmniauthHelper
    # Public: returns true if the social provider is enabled
    def social_provider_enabled?(provider)
      Rails.application.secrets.omniauth.dig(provider.to_s, "enabled")
    end

    # Public: returns true if any provider is enabled
    def any_social_provider_enabled?
      User.omniauth_providers.any? do |provider|
        social_provider_enabled? provider
      end
    end
  end
end
