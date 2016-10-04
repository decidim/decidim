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

      def install
        route "mount Decidim::System::Engine => '/system'"
        route "mount Decidim::Admin::Engine => '/admin'"
        route "mount Decidim::Core::Engine => '/'"
      end

      def copy_migrations
        rake "railties:install:migrations"
        prepare_database if options[:migrate]
      end

      def add_seeds
        append_file "db/seeds.rb", "\nDecidim.seed!"
      end

      def copy_initializer
        template "initializer.rb", "config/initializers/decidim.rb"
      end

      def insert_into_layout
        inject_into_file "app/views/layouts/application.html.erb",
                         before: "</head>" do
          "  <%= render partial: 'layouts/decidim/meta' %>\n  "
        end

        inject_into_file "app/views/layouts/application.html.erb",
                         after: "<body>" do
          "\n    <%= render partial: 'layouts/decidim/header' %>"
        end

        inject_into_file "app/views/layouts/application.html.erb",
                         before: "</body>" do
          "  <%= render partial: 'layouts/decidim/footer' %>\n  "
        end
      end

      def replace_title
        gsub_file "app/views/layouts/application.html.erb",
                  %r{<title>(.*)</title>},
                  "<title><%= decidim_page_title %></title>"
      end

      def append_assets
        append_file "app/assets/javascripts/application.js", "//= require decidim"
        inject_into_file "app/assets/stylesheets/application.css",
                         before: "*= require_tree ." do
          "*= require decidim\n"
        end
      end

      def test_mail_host
        inject_into_file "config/environments/test.rb",
                         after: "config.action_mailer.delivery_method = :test" do
          "\n  config.action_mailer.default_url_options = { host: \"test.decidim.org\" }"
        end
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

      def smtp_secrets
        inject_into_file "config/secrets.yml",
                         after: "secret_key_base: <%= ENV[\"SECRET_KEY_BASE\"] %>" do
          %(
  sendgrid: <%= !ENV["SENDGRID_USERNAME"].blank? %>
  smtp_username: <%= ENV["SMTP_USERNAME"] || ENV["SENDGRID_USERNAME"] %>
  smtp_password: <%= ENV["SMTP_PASSWORD"] || ENV["SENDGRID_PASSWORD"] %>
  smtp_address: <%= ENV["SMTP_ADDRESS"] || "smtp.sendgrid.net" %>
  smtp_domain: <%= ENV["SMTP_DOMAIN"] || "heroku.com" %>
  smtp_port: "587"
  smtp_starttls_auto: true
  smtp_authentication: "plain"
          )
        end
      end

      private

      def prepare_database
        rake "db:drop RAILS_ENV=test"
        rake "db:create RAILS_ENV=test"
        rake "db:migrate RAILS_ENV=test"
        rake "db:test:prepare"
      end
    end
  end
end
