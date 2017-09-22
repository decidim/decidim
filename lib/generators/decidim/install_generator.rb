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
      source_root File.expand_path("templates", __dir__)

      class_option :app_name, type: :string, default: nil,
                              desc: "The name of the app"
      class_option :recreate_db, type: :boolean, default: false,
                                 desc: "Recreate db after installing decidim"
      class_option :seed_db, type: :boolean, default: false,
                             desc: "Seed db after installing decidim"

      def bundle_install
        Bundler.with_clean_env { run "bundle install" }
      end

      def install
        route "mount Decidim::Core::Engine => '/'"
      end

      def add_seeds
        append_file "db/seeds.rb", <<~RUBY
          # You can remove the 'faker' gem if you don't want Decidim seeds.
          Decidim.seed!
        RUBY
      end

      def copy_migrations
        rails "railties:install:migrations"
        recreate_db if options[:recreate_db]
      end

      def copy_initializer
        template "initializer.rb", "config/initializers/decidim.rb"
        template "carrierwave.rb", "config/initializers/carrierwave.rb"
        template "social_share_button.rb", "config/initializers/social_share_button.rb"
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
        gsub_file "app/assets/javascripts/application.js", %r{//= require rails-ujs\n}, "//= require jquery\n//= require jquery_ujs\n"
        inject_into_file "app/assets/stylesheets/application.css",
                         before: "*= require_tree ." do
          "*= require decidim\n "
        end

        template "decidim.scss.erb", "app/assets/stylesheets/decidim.scss", force: true
      end

      def smtp_environment
        inject_into_file "config/environments/production.rb",
                         after: "config.log_formatter = ::Logger::Formatter.new" do
          <<~RUBY.gsub(/^ *\|/, "")
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
            |
            |  if Rails.application.secrets.sendgrid
            |    config.action_mailer.default_options = {
            |      "X-SMTPAPI" => {
            |        filters:  {
            |          clicktrack: { settings: { enable: 0 } },
            |          opentrack:  { settings: { enable: 0 } }
            |        }
            |      }.to_json
            |    }
            |  end
          RUBY
        end
      end

      def letter_opener_web
        route <<~RUBY.gsub(/^ *\|/, "")
          |
          |  if Rails.env.development?
          |    mount LetterOpenerWeb::Engine, at: "/letter_opener"
          |  end
        RUBY

        inject_into_file "config/environments/development.rb",
                         after: "config.action_mailer.raise_delivery_errors = false" do
          <<~RUBY.gsub(/^ *\|/, "")
            |
            |  config.action_mailer.delivery_method = :letter_opener_web
          RUBY
        end
      end

      private

      def recreate_db
        rails "db:environment:set", "db:drop" unless ENV["CI"]
        rails "db:create"

        if options[:seed_db]
          rails "db:migrate", "db:seed"
        else
          rails "db:migrate"
        end

        rails "db:test:prepare"
      end

      def rails(*args)
        abort unless system("bin/rails", *args)
      end

      def scss_variables
        variables = File.join(Gem.loaded_specs["decidim-core"].full_gem_path, "app", "assets", "stylesheets", "decidim", "_variables.scss")
        File.read(variables).split("\n").map { |line| "// #{line}".gsub(" !default", "") }.join("\n")
      end
    end
  end
end
