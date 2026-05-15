# frozen_string_literal: true

def setup_provider_proc(provider, config_mapping = {})
  lambda do |env|
    request = Rack::Request.new(env)
    organization = Decidim::Organization.find_by(host: request.host)
    provider_config = organization.enabled_omniauth_providers[provider]

    config_mapping.each do |option_key, config_key|
      env["omniauth.strategy"].options[option_key] = provider_config[config_key]
    end
  end
end

Rails.application.config.middleware.use OmniAuth::Builder do
  omniauth_config = Decidim.omniauth_providers

  if omniauth_config
    if omniauth_config[:developer].present?
      provider(
        :developer,
        fields: [:name, :nickname, :email]
      )
    end

    if omniauth_config[:decidim].present?
      provider(
        :decidim,
        setup: setup_provider_proc(:decidim, client_id: :client_id, client_secret: :client_secret, site: :site_url)
      )
    end

    if omniauth_config[:facebook].present?
      provider(
        :facebook,
        setup: setup_provider_proc(:facebook, client_id: :app_id, client_secret: :app_secret),
        scope: :email,
        info_fields: "name,email,verified"
      )
    end

    if omniauth_config[:twitter].present?
      provider(
        :twitter,
        setup: setup_provider_proc(:twitter, consumer_key: :api_key, consumer_secret: :api_secret)
      )
    end

    if omniauth_config[:google_oauth2].present?
      provider(
        :google_oauth2,
        setup: setup_provider_proc(:google_oauth2, client_id: :client_id, client_secret: :client_secret)
      )
    end
  end
end
