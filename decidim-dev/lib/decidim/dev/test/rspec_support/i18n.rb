# frozen_string_literal: true

RSpec.configure do |config|
  config.before(:suite) do
    I18n.config.enforce_available_locales = false
    I18n.available_locales = %w(en ca es)
    Decidim.available_locales = %w(en ca es)
  end
end
