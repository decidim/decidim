# frozen_string_literal: true

module Decidim
  module WardenTestHelpers
    include Warden::Test::Helpers

    #
    # Utility method to login in the middle of a test as a different user from
    # the current one.
    #
    def relogin_as(user, scope: :user)
      logout scope

      login_as user, scope: scope
    end
  end
end

RSpec.configure do |config|
  config.include Decidim::WardenTestHelpers, type: :feature
  config.include Devise::Test::ControllerHelpers, type: :controller

  config.after :each, type: :feature do
    Warden.test_reset!
  end
end
