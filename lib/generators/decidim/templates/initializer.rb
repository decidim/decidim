# -*- coding: utf-8 -*-
# frozen_string_literal: true
Decidim.configure do |config|
  config.application_name = "My Application Name"
  config.mailer_sender    = "change-me@domain.org"
  config.authorization_handlers = [ExampleAuthorizationHandler]

  # Uncomment this lines to set your preferred locales
  # config.available_locales = %i{en ca es}

  # Geocoder configuration
  # config.geocoder = {
  #   here_app_id: Rails.application.secrets.geocoder["here_app_id"],
  #   here_app_code: Rails.application.secrets.geocoder["here_app_code"]
  # }

  # Currency unit
  # config.currency_unit = "€"
end
