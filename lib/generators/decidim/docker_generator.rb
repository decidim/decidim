# frozen_string_literal: true

require "rails/generators"
require "generators/decidim/app_generator"

module Decidim
  module Generators
    # Generates a development Rails app that works with Docker.
    class DockerGenerator < Rails::Generators::Base
      desc "Generate a docker app for development purposes"

      class_option :docker_app_path, type: :string,
                                     desc: "The path to generate the docker app"

      source_root File.expand_path("templates", __dir__)

      def source_paths
        [
          File.expand_path("templates", __dir__)
        ]
      end

      def cleanup
        remove_directory_if_exists
      end

      def create_rails_app
        Decidim::Generators::AppGenerator.start([docker_app_path, "--demo"])
      end

      def build_docker
        remove_file "#{docker_app_path}/Dockerfile"
        template "Dockerfile.dev", "#{docker_app_path}/Dockerfile"
        inside(docker_app_path) do
          gsub_file "Gemfile",
                    /gem "decidim([^"]*)".*/,
                    'gem "decidim\1", path: "/decidim"'

          run "docker-compose build"
          run "docker-compose run --rm app rails db:drop db:create db:migrate db:setup"
        end
      end

      def after_install
        say "Docker development app generated! To start the app just run:"
        say "cd docker_development_app && docker-compose up"
        say "Open the app at http://localhost:3000"
      end

      private

      def remove_directory_if_exists
        remove_dir(docker_app_path) if File.directory?(docker_app_path)
      end

      def docker_app_path
        options[:docker_app_path]
      end
    end
  end
end
