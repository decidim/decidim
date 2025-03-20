# frozen_string_literal: true

module Decidim
  # Helper that provides methods to enable or disable omniauth buttons
  module OmniauthHelper
    # Public: normalize providers names to they can be used for buttons
    # and icons.
    def normalize_provider_name(provider)
      return "x" if provider == :twitter

      provider.to_s.split("_").first
    end

    # Public: icon for omniauth buttons
    def oauth_icon(provider)
      info = current_organization.enabled_omniauth_providers[provider.to_sym]

      name = normalize_provider_name(provider)
      name = "twitter-x" if provider == :twitter
      name = "#{name}-fill"

      if info
        icon_path = info[:icon_path]
        return external_icon(icon_path) if icon_path

        name = info[:icon] if info[:icon]
      end

      icon(name)
    end

    # Public: pretty print provider name
    def provider_name(provider)
      provider.to_s.gsub(/_|-/, " ").camelize
    end
  end
end
