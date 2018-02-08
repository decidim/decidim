# frozen_string_literal: true

require "bundler"
require "rails/generators"
require "rails/generators/rails/app/app_generator"
require "decidim/version"
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

      class_option :path, type: :string,
                          default: nil,
                          desc: "Path to the gem"

      class_option :edge, type: :boolean,
                          default: false,
                          desc: "Use GitHub's edge version from master branch"

      class_option :branch, type: :string,
                            default: nil,
                            desc: "Use a specific branch from GitHub's version"

      class_option :database, type: :string,
                              default: "postgresql",
                              desc: "Configure for selected database (options: #{DATABASES.join("/")})"

      class_option :recreate_db, type: :boolean,
                                 default: false,
                                 desc: "Recreate test database"

      class_option :seed_db, type: :boolean,
                             default: false,
                             desc: "Seed test database"

      class_option :app_const_base, type: :string,
                                    desc: "The application constant name"

      class_option :skip_bundle, type: :boolean,
                                 default: true,
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

        template path_to_root("Gemfile"), "Gemfile", force: true
        template path_to_root("Gemfile.lock"), "Gemfile.lock", force: true

        gem_modifier = if options[:path]
                         "path: \"#{options[:path]}\""
                       elsif options[:edge]
                         "git: \"https://github.com/decidim/decidim.git\""
                       elsif options[:branch]
                         "git: \"https://github.com/decidim/decidim.git\", branch: \"#{options[:branch]}\""
                       else
                         "\"#{Decidim.version}\""
                       end

        gsub_file "Gemfile", /gem "decidim".*/, "gem \"decidim\", #{gem_modifier}"
        gsub_file "Gemfile", /gem "decidim-dev".*/, "gem \"decidim-dev\", #{gem_modifier}"

        Bundler.with_original_env { run "bundle install" }
      end

      def add_ignore_uploads
        append_file ".gitignore", "\n# Ignore public uploads\npublic/uploads" unless options["skip_git"]
      end

      def remove_default_error_pages
        remove_file "public/404.html"
        remove_file "public/500.html"
      end

      def authorization_handler
        template "initializer.rb", "config/initializers/decidim.rb"

        template "example_authorization_handler.rb", "app/services/example_authorization_handler.rb" if options[:demo]
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

      def path_to_root(file)
        File.expand_path(File.join("..", "..", "..", file), __dir__)
      end

      def app_const_base
        options["app_const_base"] || super
      end
    end
  end
end
