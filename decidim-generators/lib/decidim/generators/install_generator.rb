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
                                  desc: "Don't generate a Gemfile for the application"

      class_option :profiling, type: :boolean,
                               default: false,
                               desc: "Add the necessary gems to profile the app"

      def install
        route "mount Decidim::Core::Engine => '/'"
      end

      def add_seeds
        append_file "db/seeds.rb", <<~RUBY
          # You can remove the 'faker' gem if you don't want Decidim seeds.
          Decidim.seed!
        RUBY
      end

      def copy_initializer
        copy_file "carrierwave.rb", "config/initializers/carrierwave.rb"
        copy_file "social_share_button.rb", "config/initializers/social_share_button.rb"
      end

      def secrets
        template "secrets.yml.erb", "config/secrets.yml", force: true
      end

      def remove_layout
        remove_file "app/views/layouts/application.html.erb"
        remove_file "app/views/layouts/mailer.text.erb"
      end

      def append_assets
        append_file "app/assets/javascripts/application.js", "//= require decidim"
        gsub_file "app/assets/javascripts/application.js", %r{//= require turbolinks\n}, ""
        inject_into_file "app/assets/stylesheets/application.css",
                         before: "*= require_tree ." do
          "*= require decidim\n "
        end

        template "decidim.scss.erb", "app/assets/stylesheets/decidim.scss", force: true
      end

      def disable_precompilation_on_demand
        %w(development test).each do |environment|
          inject_into_file "config/environments/#{environment}.rb",
                           before: /^end$/ do
            cut <<~RUBY, strip: false
              |
              |  # No precompilation on demand on first request
              |  config.assets.check_precompiled_asset = false
            RUBY
          end
        end
      end

      def configure_js_compressor
        gsub_file "config/environments/production.rb", "config.assets.js_compressor = :uglifier", "config.assets.js_compressor = Uglifier.new(:harmony => true)"
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

      def copy_migrations
        rails "decidim:upgrade"
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

      # Runs rails commands in a subprocess, and aborts if it doesn't suceeed
      def rails(*args)
        abort unless system("bin/rails", *args)
      end

      # Runs rails commands in a subprocess silencing errors, and ignores status
      def soft_rails(*args)
        system("bin/rails", *args, err: File::NULL)
      end

      def scss_variables
        variables = File.join(Gem.loaded_specs["decidim-core"].full_gem_path, "app", "assets", "stylesheets", "decidim", "_variables.scss")
        File.read(variables).split("\n").map { |line| "// #{line}".gsub(" !default", "") }.join("\n")
      end

      def cut(text, strip: true)
        cutted = text.gsub(/^ *\|/, "")
        return cutted unless strip

        cutted.rstrip
      end
    end
  end
end
