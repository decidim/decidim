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
      source_root File.expand_path("../templates", __FILE__)

      class_option :app_name, type: :string, default: nil,
                              desc: "The name of the app"
      class_option :migrate, type: :boolean, default: false,
                             desc: "Run migrations after installing decidim"
      class_option :recreate_db, type: :boolean, default: false,
                                 desc: "Run migrations after installing decidim"

      def install
        route "mount Decidim::Core::Engine => '/'"
      end

      def copy_migrations
        rake "railties:install:migrations"
        recreate_db if options[:recreate_db]
        rake "db:migrate" if options[:migrate]
      end

      def add_seeds
        append_file "db/seeds.rb", "\n# You can remove the 'faker' gem if you don't want Decidim seeds.\nDecidim.seed!"
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
        gsub_file "app/assets/javascripts/application.js", /\/\/= require turbolinks\n/, ''
        inject_into_file "app/assets/stylesheets/application.css",
                         before: "*= require_tree ." do
          "*= require decidim\n "
        end

        template "decidim.scss.erb", "app/assets/stylesheets/decidim.scss", force: true
      end

      def smtp_environment
        inject_into_file "config/environments/production.rb",
                         after: "config.log_formatter = ::Logger::Formatter.new" do
          %(

  config.action_mailer.smtp_settings = {
    :address        => Rails.application.secrets.smtp_address,
    :port           => Rails.application.secrets.smtp_port,
    :authentication => Rails.application.secrets.smtp_authentication,
    :user_name      => Rails.application.secrets.smtp_username,
    :password       => Rails.application.secrets.smtp_password,
    :domain         => Rails.application.secrets.smtp_domain,
    :enable_starttls_auto => Rails.application.secrets.smtp_starttls_auto,
    :openssl_verify_mode => 'none'
  }

  if Rails.application.secrets.sendgrid
    config.action_mailer.default_options = {
      "X-SMTPAPI" => {
        filters:  {
          clicktrack: { settings: { enable: 0 } },
          opentrack:  { settings: { enable: 0 } }
        }
      }.to_json
    }
  end
          )
        end
      end

      private

      def recreate_db
        unless ENV["CI"]
          rake "db:environment:set", env: "development"
          rake "db:drop"
        end
        rake "db:create"
        rake "db:migrate"
        rake "db:test:prepare"
      end

      def scss_variables
        variables = File.join(Gem.loaded_specs["decidim-core"].full_gem_path, "app", "assets", "stylesheets", "decidim", "_variables.scss")
        File.read(variables).split("\n").map { |line| "// #{line}".gsub(" !default", "") }.join("\n")
      end
    end
  end
end
