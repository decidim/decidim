# frozen_string_literal: true
require "rails/generators"
require "generators/decidim/app_generator"

module Decidim
  module Generators
    # Generates a dummy test Rails app for the given library folder. It uses
    # the `AppGenerator` class to actually generate the Rails app, so this
    # generator only sets the path and some flags.
    #
    # The Rails app will be installed with some flags to disable git, tests,
    # Gemfile and other options. Refer to the `create_dummy_app` method to see
    # all the flags passed to the `AppGenerator` class, which is the one that
    # actually generates the Rails app.
    #
    # Remember that, for how generators work, actions are executed based on the
    # definition order of the public methods.
    class DummyGenerator < Rails::Generators::Base
      desc "Generate dummy app for testing purposes"

      class_option :engine_path, type: :string,
                                 desc: "The library where the dummy app will be installed"

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
          "--recreate_db"
        ]
      end

      def set_locales
        inject_into_file "#{dummy_path}/config/application.rb", after: "class Application < Rails::Application" do
          "\n    config.i18n.available_locales = %w(en ca es)\n    config.i18n.default_locale = :en"
        end
      end

      def raise_on_missing_translations
        gsub_file "#{dummy_path}/config/environments/test.rb", "# config.action_view.raise_on_missing_translations", " config.action_view.raise_on_missing_translations"
      end

      private

      def dummy_path
        ENV["DUMMY_PATH"] || engine_path + "/spec/#{dir_name}_dummy_app"
      end

      def remove_directory_if_exists(path)
        remove_dir(path) if File.directory?(path)
      end

      def dir_name
        engine_path.split("/").last
      end

      def engine_path
        options[:engine_path]
      end
    end
  end
end
