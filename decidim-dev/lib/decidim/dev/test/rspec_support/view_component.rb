# frozen_string_literal: true

require "view_component/test_helpers"
require "view_component/system_test_helpers"
require "capybara/rspec"

module Decidim
  module ViewComponentTestHelpers
    def self.included(base)
      base.class_eval do
        mattr_accessor :controller_class
        def self.controller(name)
          self.controller_class = name
        end
      end
    end
  end
end

RSpec.configure do |config|
  config.include ViewComponent::TestHelpers, type: :component
  config.include ViewComponent::SystemTestHelpers, type: :component
  config.include Capybara::RSpecMatchers, type: :component
  config.include Devise::Test::ControllerHelpers, type: :component
  config.include Decidim::CapybaraTestHelpers, type: :component
  config.include Decidim::ViewComponentTestHelpers, type: :component
  
  config.before :each, type: :component do
    @request = vc_test_controller.request

    allow(vc_test_controller).to receive(:current_organization).and_return(try(:organization) || try(:current_organization) || nil)
    allow(vc_test_controller).to receive(:current_user).and_return(try(:user) || try(:current_user) || nil)
  end

  config.around :each, type: :component do |example|
    with_controller_class(controller_class) do
      example.run
    end
  end
end
