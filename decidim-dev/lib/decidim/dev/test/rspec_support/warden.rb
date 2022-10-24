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

      login_as user, scope:
    end
  end
end

RSpec.configure do |config|
  config.include Decidim::WardenTestHelpers, type: :system
  config.include Decidim::WardenTestHelpers, type: :request
  config.include Devise::Test::ControllerHelpers, type: :controller

  config.before :each, type: :cell do
    if controller
      allow(controller).to receive(:current_organization).and_return(try(:organization) || try(:current_organization) || nil)
      allow(controller).to receive(:current_user).and_return(try(:user) || try(:current_user) || nil)
    end
  end

  config.after :each, type: :system do
    Warden.test_reset!
  end

  config.after :each, type: :request do
    Warden.test_reset!
  end
end
