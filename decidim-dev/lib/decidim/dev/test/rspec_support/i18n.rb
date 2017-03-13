# frozen_string_literal: true
RSpec.configure do |config|
  config.before(:suite) do
    I18n.config.enforce_available_locales = false
  end

  config.around(:each) do |example|
    I18n.available_locales = %w{en ca es}
    Decidim.available_locales = %w{en ca es}

    previous_locale = I18n.locale
    example.run
    I18n.locale = previous_locale
  end
end
