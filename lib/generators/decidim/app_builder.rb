module Decidim
  module Generators
    class AppBuilder < Rails::AppBuilder
      def gemfile
        template "Gemfile.erb", "Gemfile"
      end
    end
  end
end
