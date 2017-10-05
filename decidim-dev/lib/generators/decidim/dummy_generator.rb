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
    # Remember that, because of how generators work, actions are executed based
    # on the definition order of the public methods.
    class DummyGenerator < Rails::Generators::Base
      desc "Generate dummy app for testing purposes"

      class_option :dummy_app_path, type: :string,
                                    desc: "The path where the dummy app will be installed"

      def source_paths
        [
          File.expand_path("templates", __dir__)
        ]
      end

      def cleanup
        remove_directory_if_exists(dummy_app_path)
      end

      def create_dummy_app
        Decidim::Generators::AppGenerator.start [
          dummy_app_path,
          "--path",
          "../..",
          "--app_const_base=DummyApplication",
          "--recreate_db",
          "--demo"
        ]
      end

      def decidim_dev
        # TODO: Remove these after PhantomJS updates WebKit version (see YML and
        #       initializer comments)
        template "autoprefixer.yml", "#{dummy_app_path}/config/autoprefixer.yml"
        template "autoprefixer_initializer.rb", "#{dummy_app_path}/config/initializers/autoprefixer.rb"

        template "no_animations.rb", "#{dummy_app_path}/app/middleware/no_animations.rb"
      end

      def test_env
        gsub_file "#{dummy_app_path}/config/environments/test.rb",
                  /allow_forgery_protection = (.*)/, "allow_forgery_protection = true"

        inject_into_file "#{dummy_app_path}/config/environments/test.rb",
                         after: "allow_forgery_protection = true\n" do
          <<~RUBY.gsub(/^ *\|/, "")
            |
            |  # Inject middleware to disable CSS animations
            |  config.middleware.use NoAnimations
            |
          RUBY
        end
      end

      private

      def dummy_app_path
        options[:dummy_app_path]
      end

      def remove_directory_if_exists(path)
        remove_dir(path) if File.directory?(path)
      end
    end
  end
end
