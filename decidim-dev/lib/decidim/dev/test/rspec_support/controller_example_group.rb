# frozen_string_literal: true

module Decidim
  module ControllerExampleGroup
    extend ActiveSupport::Concern

    class_methods do
      def routes
        before do
          routes = yield
          @orig_default_url_options = routes.default_url_options.dup
          routes.default_url_options[:script_name] = ""

          self.routes = routes
        end

        after do
          routes.default_url_options = @orig_default_url_options
        end
      end
    end
  end
end

RSpec.configure do |config|
  config.include Decidim::ControllerExampleGroup, type: :controller
end
