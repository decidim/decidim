# frozen_string_literal: true
require "rails/generators"
require "rails/generators/rails/app/app_generator"
require "decidim/core/version"
require_relative "app_builder"
require_relative "install_generator"

module Decidim
  module Generators
    # Generates a Rails app and installs decidim to it. Uses the default Rails
    # generator for most of the work.
    #
    # Remember that, for how generators work, actions are executed based on the
    # definition order of the public methods.
    class DemoGenerator < Rails::Generators::Base
      def authorization_handlers
        remove_file "app/services/example_authorization_handler.rb"
        inject_into_file "config/initializers/decidim.rb", before: "Decidim" do
          "require \"decidim/dummy_authorization_handler\" \n"
        end
        gsub_file "config/initializers/decidim.rb",
                  /ExampleAuthorizationHandler/,
                  "Decidim::DummyAuthorizationHandler"
      end
    end
  end
end
