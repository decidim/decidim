# frozen_string_literal: true
require "rails/generators"
require_relative "../../../../lib/generators/decidim/app_generator"

module Decidim
  module System
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

        class_option :lib_name, type: :string,
                                desc: "The library where the dummy app will be installed"

        class_option :migrate, type: :boolean, default: false,
                               desc: "Run migrations after installing decidim"

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
            "--migrate=#{options[:migrate]}"
          ]
        end

        private

        def dummy_path
          ENV["DUMMY_PATH"] || "spec/#{short_lib_name}_dummy"
        end

        def remove_directory_if_exists(path)
          remove_dir(path) if File.directory?(path)
        end

        def short_lib_name
          options[:lib_name].split("/").last
        end
      end
    end
  end
end
