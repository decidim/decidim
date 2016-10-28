# frozen_string_literal: true
RSpec.configure do |config|
  config.before(:suite) do
    I18n.available_locales = [:dev, :en]
    I18n::Backend::Simple.send(:include, I18n::Backend::Fallbacks)
    I18n.locale = :dev
    I18n.fallbacks.map("dev" => "en")
    I18n.config.enforce_available_locales = false
  end

  config.around(:each) do |example|
    previous_locale = I18n.locale
    example.run
    I18n.locale = previous_locale
  end
end
