# frozen_string_literal: true

RSpec.configure do |config|
  config.before(:suite) do
    I18n.config.enforce_available_locales = false
    Decidim.available_locales = %w(en ca es)
    I18n.available_locales = Decidim.available_locales
  end
end
