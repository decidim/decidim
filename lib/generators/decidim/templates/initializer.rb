# frozen_string_literal: true
Decidim.configure do |config|
  config.application_name = "My Application Name"
  config.mailer_sender    = "change-me@domain.org"
  config.authorization_handlers = [ExampleAuthorizationHandler]

  # Uncomment this lines to set your preferred locales
  # config.available_locales = %{en ca es}
end
