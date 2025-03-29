# frozen_string_literal: true

require "rails/generators/base"
require "securerandom"

module Decidim
  module Generators
    # Installs `decidim` to a Rails app by adding the needed lines of code
    # automatically to important files in the Rails app.
    #
    # Remember that, for how generators work, actions are executed based on the
    # definition order of the public methods.
    class InstallGenerator < Rails::Generators::Base
      desc "Install decidim"
      source_root File.expand_path("app_templates", __dir__)

      class_option :app_name, type: :string,
                              default: nil,
                              desc: "The name of the app"

      class_option :recreate_db, type: :boolean,
                                 default: false,
                                 desc: "Recreate db after installing decidim"

      class_option :seed_db, type: :boolean,
                             default: false,
                             desc: "Seed db after installing decidim"

      class_option :skip_gemfile, type: :boolean,
                                  default: false,
                                  desc: "Do not generate a Gemfile for the application"

      class_option :profiling, type: :boolean,
                               default: false,
                               desc: "Add the necessary gems to profile the app"

      def install
        route "mount Decidim::Core::Engine => '/'"
      end

      def add_seeds
        append_file "db/seeds.rb", <<~RUBY
          # You can remove the 'faker' gem if you do not want Decidim seeds.
          Decidim.seed!
        RUBY
      end

      def remove_layout
        remove_file "app/views/layouts/application.html.erb"
        remove_file "app/views/layouts/mailer.text.erb"
      end

      def smtp_environment
        inject_into_file "config/environments/production.rb",
                         after: "config.log_tags = [ :request_id ]" do
          cut <<~HERE
            |
            |  config.action_mailer.smtp_settings = {
            |    :address        => Decidim::Env.new("SMTP_ADDRESS").to_s,
            |    :port           => Decidim::Env.new("SMTP_PORT", 587).to_i,
            |    :authentication => Decidim::Env.new("SMTP_AUTHENTICATION", "plain").to_s,
            |    :user_name      => Decidim::Env.new("SMTP_USERNAME").to_s,
            |    :password       => Decidim::Env.new("SMTP_PASSWORD").to_s,
            |    :domain         => Decidim::Env.new("SMTP_DOMAIN").to_s,
            |    :enable_starttls_auto => Decidim::Env.new("SMTP_STARTTLS_AUTO").to_boolean_string,
            |    :openssl_verify_mode => 'none'
            |  }
          HERE
        end
      end

      def skip_gemfile_if_defined
        return unless options[:skip_gemfile]

        remove_file "Gemfile"
      end

      def install_decidim_webpacker
        # Copy CSS file
        copy_file "decidim_application.scss", "app/packs/stylesheets/decidim/decidim_application.scss"

        # Copy JS application file
        copy_file "decidim_application.js", "app/packs/src/decidim/decidim_application.js"

        # Create empty directory for images
        empty_directory "app/packs/images"
        # Add a .keep file so directory is included in git when committing
        create_file "app/packs/images/.keep"

        # Regenerate webpacker binstubs
        remove_file "bin/yarn"
        bundle_install
        rails "shakapacker:binstubs"

        # Copy package.json
        copy_file "package.json", "package.json"

        # Run Decidim custom webpacker installation
        rails "decidim:webpacker:install"

        # Run Decidim custom procfile installation
        rails "decidim:procfile:install"

        # Replace robots.txt
        remove_file "public/robots.txt"
        rails "decidim:robots:replace"
      end

      def build_api_docs
        rails "decidim_api:generate_docs"
      end

      def letter_opener_web
        route <<~RUBY
          if Rails.env.development?
            mount LetterOpenerWeb::Engine, at: "/letter_opener"
          end

        RUBY

        inject_into_file "config/environments/development.rb",
                         after: "config.action_mailer.raise_delivery_errors = false" do
          cut <<~HERE
            |
            |  config.action_mailer.delivery_method = :letter_opener_web
            |  config.action_mailer.default_url_options = { port: 3000 }
          HERE
        end
      end

      def profiling_gems
        return unless options[:profiling]

        append_file "Gemfile", <<~RUBY

          group :development do
            # Profiling gems
            gem "bullet"
            gem "flamegraph"
            gem "memory_profiler"
            gem "rack-mini-profiler", require: false
            gem "stackprof"
          end
        RUBY

        copy_file "bullet_initializer.rb", "config/initializers/bullet.rb"
        copy_file "rack_profiler_initializer.rb", "config/initializers/rack_profiler.rb"
      end

      def tweak_spring
        run "bundle exec spring stop"
        run "bundle exec spring binstub --all"

        create_file "config/spring.rb", <<~CONFIG
          require "decidim/spring"

          Spring.watch(
            ".ruby-version",
            ".rbenv-vars",
            "tmp/restart.txt",
            "tmp/caching-dev.txt"
          )
        CONFIG
      end

      def bundle_install
        run "bundle install"
      end

      def copy_migrations
        rails "decidim:choose_target_plugins", "railties:install:migrations"
        recreate_db if options[:recreate_db]
      end

      private

      def recreate_db
        soft_rails "db:environment:set", "db:drop"
        rails "db:create"

        rails "db:migrate"

        rails "assets:precompile"

        rails "--trace", "db:seed" if options[:seed_db]

        rails "db:test:prepare"
      end

      # Runs rails commands in a subprocess, and aborts if it does not succeed
      def rails(*)
        abort unless system("bin/rails", *)
      end

      # Runs rails commands in a subprocess silencing errors, and ignores status
      def soft_rails(*)
        system("bin/rails", *, err: File::NULL)
      end

      def cut(text, strip: true)
        cutted = text.gsub(/^ *\|/, "")
        return cutted unless strip

        cutted.rstrip
      end
    end
  end
end
