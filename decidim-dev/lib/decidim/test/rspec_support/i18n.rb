# frozen_string_literal: true
RSpec.configure do |config|
  config.before(:suite) do
    I18n::Backend::Simple.send(:include, I18n::Backend::Fallbacks)
    I18n.fallbacks.map("dev" => "en")
    I18n.config.enforce_available_locales = false
  end

  config.before(:each) do
    I18n.available_locales = [:dev, :en]
    I18n.locale = :dev
  end
end
