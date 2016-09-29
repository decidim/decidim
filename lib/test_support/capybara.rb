# frozen_string_literal: true
def switch_to_host(host = "lvh.me")
  app_host = (host ? "http://#{host}" : nil)
  Capybara.app_host = app_host
end

def switch_to_default_host
  switch_to_host nil
end

Capybara.configure do |config|
  config.always_include_port = true
end

RSpec.configure do |config|
  config.before :each, type: :feature do
    switch_to_default_host
  end
end
