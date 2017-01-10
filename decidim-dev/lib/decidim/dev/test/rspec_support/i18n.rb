# frozen_string_literal: true
RSpec.configure do |config|
  config.before(:suite) do
    I18n.config.enforce_available_locales = false
    Rails.application.config.action_view.raise_on_missing_translations = true
  end

  config.around(:each) do |example|
    previous_locale = I18n.locale
    example.run
    I18n.locale = previous_locale
  end
end
