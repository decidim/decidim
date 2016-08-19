require 'rails/generators'
require 'rails/generators/rails/app/app_generator'
require_relative 'app_builder'
require 'generators/decidim/install_generator'

module Decidim
  module Generators
    class AppGenerator < Rails::Generators::AppGenerator
      hide!

      source_root File.expand_path('../templates', __FILE__)

      def source_paths
        [
          File.expand_path('../templates', __FILE__),
          File.expand_path(File.join(Gem::Specification.
                                                  find_by_name("railties").gem_dir,
                                                "lib","rails", "generators", "rails",
                                                "app", "templates"))

        ]
      end

      class_option :path, type: :string, default: nil,
                   desc: "Path to the gem"

      class_option :edge, type: :boolean, default: false,
                   desc: "Use github's edge version"

      class_option :database, type: :string, aliases: "-d", default: "postgresql",
                  desc: "Configure for selected database (options: #{DATABASES.join("/")})"

      def cleanup
        p options
        # remove_directory_if_exists(dummy_path)
      end

      def install
        Decidim::Generators::InstallGenerator.start
      end

      private

      def get_builder_class
        AppBuilder
      end
    end
  end
end
