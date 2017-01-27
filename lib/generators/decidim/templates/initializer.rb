# frozen_string_literal: true
Decidim.configure do |config|
  config.application_name = "My Application Name"
  config.mailer_sender    = "change-me@domain.org"
  config.authorization_handlers = [ExampleAuthorizationHandler]

  # Uncomment this lines to set your preferred locales
  # config.available_locales = %i{en ca es}

  # Geocoder configuration
  # config.geocoder = {
  #   lookup: Rails.application.secets.geocoder["lookup"]
  #   api_key: [
  #     Rails.application.secets.geocoder["api_key"].first,
  #     Rails.application.secets.geocoder["api_key"].last
  #   ]
  # }
end
