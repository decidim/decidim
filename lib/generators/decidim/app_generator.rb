# frozen_string_literal: true

require "rails/generators"
require "rails/generators/rails/app/app_generator"
require_relative "../../decidim/version"
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

      class_option :skip_gemfile, type: :boolean,
                                  default: false,
                                  desc: "Don't generate a Gemfile for the application"

      class_option :demo, type: :boolean, default: false,
                          desc: "Generate a demo authorization handler"

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
        return if options[:skip_gemfile]

        path = File.expand_path(File.join("..", "..", "..", "Gemfile"), __dir__)

        template path, "Gemfile", force: true

        gem_modifier = if options[:path]
                         "path: \"#{options[:path]}\""
                       elsif options[:edge]
                         "git: \"https://github.com/decidim/decidim.git\""
                       elsif options[:branch]
                         "git: \"https://github.com/decidim/decidim.git\", branch: \"#{options[:branch]}\""
                       else
                         "\"#{Decidim.version}\""
                       end

        gsub_file "Gemfile", /gem "decidim([^"]*)".*/, "gem \"decidim\\1\", #{gem_modifier}"
        run "bundle install"
      end

      def bootsnap
        append_file "config/boot.rb", "require 'bootsnap/setup'\n"
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
        template "initializer.rb", "config/initializers/decidim.rb"

        auth_handler = if options[:demo]
                         "decidim/dummy_authorization_handler"
                       else
                         "example_authorization_handler"
                       end

        template "#{auth_handler}.rb", "app/services/#{auth_handler}.rb"

        gsub_file "config/initializers/decidim.rb",
                  /config\.mailer_sender = "change-me@domain\.org"/ do |match|
          match << "\n  config.authorization_handlers = [\"#{auth_handler.classify}\"]"
        end
      end

      def install
        Decidim::Generators::InstallGenerator.start(
          [
            "--recreate_db=#{options[:recreate_db]}",
            "--seed_db=#{options[:seed_db]}",
            "--app_name=#{app_name}"
          ]
        )
      end

      private

      def app_const_base
        options["app_const_base"] || super
      end
    end
  end
end
