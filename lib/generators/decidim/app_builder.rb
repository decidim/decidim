# frozen_string_literal: true
module Decidim
  module Generators
    # Custom app builder to inject own Gemfile.
    class AppBuilder < Rails::AppBuilder
      def gemfile
        template "Gemfile.erb", "Gemfile"
      end

      def docker
        template "Dockerfile.erb", "Dockerfile"
        template "docker-compose.yml.erb", "docker-compose.yml"
      end
    end
  end
end
