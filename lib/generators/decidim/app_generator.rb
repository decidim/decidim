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
    class AppGenerator < Rails::Generators::AppGenerator
      hide!

      source_root File.expand_path("../templates", __FILE__)

      def source_paths
        [
          File.expand_path("../templates", __FILE__),
          File.expand_path(File.join(Gem::Specification
                                                  .find_by_name("railties").gem_dir,
                                     "lib", "rails", "generators", "rails",
                                     "app", "templates"))

        ]
      end

      class_option :path, type: :string, default: nil,
                          desc: "Path to the gem"

      class_option :edge, type: :boolean, default: false,
                          desc: "Use GitHub's edge version"

      class_option :database, type: :string, aliases: "-d", default: "postgresql",
                              desc: "Configure for selected database (options: #{DATABASES.join("/")})"

      class_option :migrate, type: :boolean, default: false,
                             desc: "Run migrations after installing decidim"

      def install
        Decidim::Generators::InstallGenerator.start [
          "--migrate=#{options[:migrate]}",
          "--app_name=#{app_name}"
        ]
      end

      def docker
        template "Dockerfile.erb", "Dockerfile"
        template "docker-compose.yml.erb", "docker-compose.yml"
      end

      def database_yml
        template "database.yml.erb", "config/database.yml", force: true
      end

      def cable_yml
        template "cable.yml.erb", "config/cable.yml", force: true
      end

      def readme
        template "README.md.erb", "README.md", force: true
      end

      def secret_token
        require "securerandom"
        SecureRandom.hex(64)
      end

      def app_json
        template "app.json.erb", "app.json"
      end

      private

      def get_builder_class
        AppBuilder
      end
    end
  end
end
