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

      class_option :migrate, type: :boolean, default: false,
                             desc: "Run migrations after installing decidim"

      def install
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
          "*= require decidim\n "
        end
      end

      private

      def prepare_database
        rake "db:drop"
        rake "db:create"
        rake "db:migrate"
      end
    end
  end
end
