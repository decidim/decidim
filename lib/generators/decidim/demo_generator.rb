# frozen_string_literal: true

require "rails/generators"
require "rails/generators/rails/app/app_generator"
require "decidim/core/version"

module Decidim
  module Generators
    # Modifies an existing decidim app so it can be used as a demo of Decidim.
    class DemoGenerator < Rails::Generators::Base
      def source_paths
        [
          File.expand_path("../../../decidim-dev/lib/decidim/dev", __dir__)
        ]
      end

      def authorization_handlers
        remove_file "app/services/example_authorization_handler.rb"
        template "dummy_authorization_handler.rb", "app/services/decidim/dummy_authorization_handler.rb"
        gsub_file "config/initializers/decidim.rb",
                  /ExampleAuthorizationHandler/,
                  "Decidim::DummyAuthorizationHandler"
      end
    end
  end
end
