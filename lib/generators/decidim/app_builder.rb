# frozen_string_literal: true
module Decidim
  module Generators
    # Custom app builder to inject own Gemfile.
    class AppBuilder < Rails::AppBuilder
      def gemfile
        template "Gemfile.erb", "Gemfile"
      end
    end
  end
end
