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
        append_file "db/seeds.rb", "Decidim::Core::Engine.load_seed"
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

      private

      def prepare_database
        rake "db:drop RAILS_ENV=development"
        rake "db:create RAILS_ENV=development"
        rake "db:migrate RAILS_ENV=development"
        rake "db:test:prepare"
      end
    end
  end
end
