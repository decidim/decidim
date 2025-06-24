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
      provider_info = current_organization.enabled_omniauth_providers[provider.to_sym]

      name = normalize_provider_name(provider)
      name = "twitter-x" if provider == :twitter
      name = "#{name}-fill"

      if provider_info
        icon_path = provider_info[:icon_path] || Rails.application.secrets.omniauth[provider][:icon_path].presence
        return external_icon(icon_path) if icon_path.present?

        name = provider_info[:icon] if provider_info[:icon]
      end

      icon(name)
    end

    # Public: pretty print provider name
    def provider_name(provider)
      provider.to_s.gsub(/_|-/, " ").camelize
    end
  end
end
