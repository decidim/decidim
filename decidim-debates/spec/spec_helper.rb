# frozen_string_literal: true

require "decidim/dev"

ENV["ENGINE_NAME"] = File.dirname(File.dirname(__FILE__)).split("/").last

Decidim::Dev.dummy_app_path = File.expand_path(File.join("..", "spec", "decidim_dummy_app"))

require "decidim/dev/test/base_spec_helper"

RSpec.configure do |config|
  config.before(:each) do
    I18n.available_locales = %i(en ca es)
    I18n.default_locale = :en
    I18n.locale = :en
    Decidim.available_locales = %i(en ca es)
    Decidim.default_locale = :en
  end
end
