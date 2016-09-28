RSpec.configure do |config|
  config.include Warden::Test::Helpers, type: :feature

  config.after :each, type: :feature do
    Warden.test_reset!
  end
end
