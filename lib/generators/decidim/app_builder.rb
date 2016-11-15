# frozen_string_literal: true
require "decidim/core"

module Decidim
  module Generators
    # Custom app builder to inject own Gemfile.
    class AppBuilder < Rails::AppBuilder
      def gemfile
        template "Gemfile.erb", "Gemfile", rails_version: Decidim.rails_version
      end
    end
  end
end
