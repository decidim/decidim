# frozen_string_literal: true

require "rails/generators"
require "rails/generators/rails/app/app_generator"
require "decidim/core/version"
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

      def source_paths
        [
          File.expand_path("templates", __dir__),
          Rails::Generators::AppGenerator.source_root
        ]
      end

      source_root File.expand_path("templates", __dir__)

      class_option :path, type: :string, default: nil,
                          desc: "Path to the gem"

      class_option :edge, type: :boolean, default: false,
                          desc: "Use GitHub's edge version from master branch"

      class_option :branch, type: :string, default: nil,
                            desc: "Use a specific branch from GitHub's version"

      class_option :database, type: :string, aliases: "-d", default: "postgresql",
                              desc: "Configure for selected database (options: #{DATABASES.join("/")})"

      class_option :recreate_db, type: :boolean, default: false,
                                 desc: "Recreate test database"

      class_option :seed_db, type: :boolean, default: false,
                             desc: "Seed test database"

      class_option :app_const_base, type: :string,
                                    desc: "The application constant name"

      class_option :skip_bundle, type: :boolean, aliases: "-B", default: true,
                                 desc: "Don't run bundle install"

      def database_yml
        template "database.yml.erb", "config/database.yml", force: true
      end

      def decidim_controller
        template "decidim_controller.rb.erb", "app/controllers/decidim_controller.rb", force: true
      end

      def docker
        template "Dockerfile.erb", "Dockerfile"
        template "docker-compose.yml.erb", "docker-compose.yml"
      end

      def cable_yml
        template "cable.yml.erb", "config/cable.yml", force: true
      end

      def readme
        template "README.md.erb", "README.md", force: true
      end

      def gemfile
        template "Gemfile.erb", "Gemfile", force: true
      end

      def install
        Decidim::Generators::InstallGenerator.start [
          "--recreate_db=#{options[:recreate_db]}",
          "--seed_db=#{options[:seed_db]}",
          "--app_name=#{app_name}"
        ]
      end

      def add_ignore_uploads
        unless options["skip_git"]
          append_file ".gitignore", "\n# Ignore public uploads\npublic/uploads"
        end
      end

      def remove_default_error_pages
        remove_file "public/404.html"
        remove_file "public/500.html"
      end

      def authorization_handler
        template "authorization_handler.rb", "app/services/example_authorization_handler.rb", force: true
      end

      private

      def app_const_base
        options["app_const_base"] || super
      end
    end
  end
end
