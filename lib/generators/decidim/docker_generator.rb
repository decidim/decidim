# frozen_string_literal: true
require "rails/generators"
require "generators/decidim/app_generator"

module Decidim
  module Generators
    # Generates a development Rails app that works with Docker.
    class DockerGenerator < Rails::Generators::Base
      desc "Generate a docker app for development purposes"

      class_option :path, type: :string,
                          desc: "The path to generate the docker app"

      source_root File.expand_path("../templates", __FILE__)

      def source_paths
        [
          File.expand_path("../templates", __FILE__)
        ]
      end

      def cleanup
        remove_directory_if_exists
      end

      def create_rails_app
        Decidim::Generators::AppGenerator.start([path])
      end

      def build_docker
        remove_file "#{path}/Dockerfile"
        template "Dockerfile.dev.erb", "#{path}/Dockerfile"
        inside(path) do
          gsub_file "Gemfile",
                    /gem "decidim(.*)"/,
                    'gem "decidim", path: "/decidim"'

          run "rails generate decidim:demo"
          run "docker-compose build"
          run "docker-compose run --rm app rake db:drop db:create db:migrate db:setup"
        end
      end

      def after_install
        puts "Docker development app generated! To start the app just run:"
        puts "cd docker_development_app && docker-compose up"
        puts "Open the app at http://localhost:3000"
      end

      private

      def remove_directory_if_exists
        remove_dir(path) if File.directory?(path)
      end

      def path
        options[:path]
      end
    end
  end
end
