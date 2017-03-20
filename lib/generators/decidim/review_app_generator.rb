# frozen_string_literal: true
require "rails/generators"
require "rails/generators/rails/app/app_generator"
require "decidim/core/version"
require_relative "app_builder"
require_relative "install_generator"

module Decidim
  module Generators
    # Modifies an existing decidim app so it works as a Heroku review app.
    class ReviewAppGenerator < Rails::Generators::Base
      def source_paths
        [
          File.expand_path("../../../../decidim-dev/lib/decidim/dev", __FILE__)
        ]
      end

      def modify_app_json_file
        gsub_file("app.json", "\"env\": {", <<-APP_JSON_CONTENT)
"scripts": {
    "postdeploy":"rake db:schema:load db:migrate db:seed"
  },
  "env": {
    "AWS_ACCESS_KEY_ID": {
      "required": true
    },
    "AWS_SECRET_ACCESS_KEY": {
      "required": true
    },
    "HERE_APP_ID": {
      "required": false
    },
    "HERE_APP_CODE": {
      "required": false
    },
    "HEROKU_APP_NAME": {
      "required": true
    },
APP_JSON_CONTENT
      end

      def modify_initializer
        gsub_file("config/initializers/decidim.rb", /^end/, <<-INITIALIZER_CONTENT)

  if ENV["HEROKU_APP_NAME"].present?
    config.base_uploads_path = ENV["HEROKU_APP_NAME"] + "/"
  end
end
INITIALIZER_CONTENT
      end
    end
  end
end
