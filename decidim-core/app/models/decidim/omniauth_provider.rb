# frozen_string_literal: true

module Decidim
  class OmniauthProvider
    def self.available
      Decidim.omniauth_providers
    end

    def self.enabled
      available.select do |_provider, settings|
        settings[:enabled] == true
      end
    end

    def self.extract_provider_key(enabled_setting_key)
      enabled_setting_key.gsub("omniauth_settings_", "")
                         .gsub("_enabled", "").to_sym
    end

    def self.extract_setting_key(setting_key, provider)
      setting_key.gsub("omniauth_settings_#{provider}_", "").to_sym
    end

    def self.value_defined?(value)
      value.is_a?(String) && value.present?
    end
  end
end
