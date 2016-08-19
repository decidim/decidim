require 'rails/generators'
require_relative '../../../../lib/generators/decidim/app_generator'

module Decidim
  module Generators
    class DummyGenerator < Rails::Generators::Base
      desc "Generate dummy app for testing purposes"

      class_option :lib_name, default: ''

      def inspect_params
        p options
      end

      def cleanup
        remove_directory_if_exists(dummy_path)
      end

      def create_dummy_app
        Decidim::Generators::AppGenerator.start [
          dummy_path,
          "--skip_gemfile",
          "--skip-bundle",
          "--skip-git",
          "--skip-keeps",
          "--skip-test",
        ]

        rake "db:migrate"
      end

      private

      def dummy_path
        ENV['DUMMY_PATH'] || "spec/#{short_lib_name}_dummy"
      end

      def remove_directory_if_exists(path)
        remove_dir(path) if File.directory?(path)
      end

      def short_lib_name
        options[:lib_name].split('/').last
      end
    end
  end
end
