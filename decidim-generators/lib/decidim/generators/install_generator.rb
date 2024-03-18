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

      def secrets
        template "secrets.yml.erb", "config/secrets.yml", force: true
      end

      def remove_layout
        remove_file "app/views/layouts/application.html.erb"
        remove_file "app/views/layouts/mailer.text.erb"
      end

      def smtp_environment
        inject_into_file "config/environments/production.rb",
                         after: "config.log_formatter = ::Logger::Formatter.new" do
          cut <<~RUBY
            |
            |  config.action_mailer.smtp_settings = {
            |    :address        => Rails.application.secrets.smtp_address,
            |    :port           => Rails.application.secrets.smtp_port,
            |    :authentication => Rails.application.secrets.smtp_authentication,
            |    :user_name      => Rails.application.secrets.smtp_username,
            |    :password       => Rails.application.secrets.smtp_password,
            |    :domain         => Rails.application.secrets.smtp_domain,
            |    :enable_starttls_auto => Rails.application.secrets.smtp_starttls_auto,
            |    :openssl_verify_mode => 'none'
            |  }
          RUBY
        end
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

      def remove_old_assets
        remove_file "config/initializers/assets.rb"
        remove_dir("app/assets")
        remove_dir("app/javascript")
      end

      def remove_sprockets_requirement
        gsub_file "config/application.rb", %r{require ['"]rails/all['"]\R}, <<~RUBY
          require "decidim/rails"

          # Add the frameworks used by your app that are not loaded by Decidim.
          # require "action_mailbox/engine"
          # require "action_text/engine"
          require "action_cable/engine"
          require "rails/test_unit/railtie"
        RUBY

        gsub_file "config/environments/development.rb", /config\.assets.*$/, ""
        gsub_file "config/environments/test.rb", /config\.assets.*$/, ""
        gsub_file "config/environments/production.rb", /config\.assets.*$/, ""
      end

      def copy_migrations
        rails "decidim:choose_target_plugins", "railties:install:migrations"
        recreate_db if options[:recreate_db]
      end

      def letter_opener_web
        route <<~RUBY
          if Rails.env.development?
            mount LetterOpenerWeb::Engine, at: "/letter_opener"
          end

        RUBY

        inject_into_file "config/environments/development.rb",
                         after: "config.action_mailer.raise_delivery_errors = false" do
          cut <<~RUBY
            |
            |  config.action_mailer.delivery_method = :letter_opener_web
            |  config.action_mailer.default_url_options = { port: 3000 }
          RUBY
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

      def bundle_install
        run "bundle install"
      end

      private

      def recreate_db
        soft_rails "db:environment:set", "db:drop"
        rails "db:create"

        rails "db:migrate"

        rails "db:seed" if options[:seed_db]

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
