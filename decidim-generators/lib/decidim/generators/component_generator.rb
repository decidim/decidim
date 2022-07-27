#!/usr/bin/env ruby
# frozen_string_literal: true

require "bundler"
require "thor"
require "active_support/inflector"
require "decidim/core/version"

module Decidim
  module Generators
    class ComponentGenerator < Thor
      include Thor::Actions

      attr_reader :component_name, :component_module_name, :component_resource_name, :component_folder, :component_description, :core_version, :required_ruby_version, :security_email

      source_root File.expand_path("component_templates", __dir__)

      desc "component COMPONENT_NAME", "Generate a decidim component"

      method_options destination_folder: :string, external: :boolean

      def component(component_name)
        @component_name = component_name
        @component_module_name = component_name.camelize
        @component_folder = options[:destination_folder] || "decidim-module-#{component_name}"
        @core_version = Decidim::Core.version
        @component_description = ask "Write a description for the new component:"
        @required_ruby_version = RUBY_VERSION.length == 5 ? RUBY_VERSION[0..2] : RUBY_VERSION
        @security_email = ask "Provide a public email in case of security concern:"
        format_email!

        template "decidim-component.gemspec.erb", "#{component_folder}/decidim-#{component_name}.gemspec"
        template "Gemfile.erb", "#{component_folder}/Gemfile" if options[:external]
        template "Rakefile", "#{component_folder}/Rakefile"
        template "LICENSE-AGPLv3.txt", "#{component_folder}/LICENSE-AGPLv3.txt"
        template "README.md.erb", "#{component_folder}/README.md"
        template "gitignore", "#{component_folder}/.gitignore"
        template "circleci/config.yml", "#{component_folder}/.circleci/config.yml"

        app_folder = "#{component_folder}/app"
        template "app/packs/js/entrypoint.js", "#{app_folder}/packs/entrypoints/decidim_#{component_name}.js"
        template "app/packs/images/decidim/component/icon.svg", "#{app_folder}/packs/images/decidim/#{component_name}/icon.svg"
        template "app/packs/stylesheets/decidim/default.scss", "#{app_folder}/packs/stylesheets/decidim/#{component_name}/#{component_name}.scss"
        template "app/controllers/decidim/component/application_controller.rb.erb", "#{app_folder}/controllers/decidim/#{component_name}/application_controller.rb"
        template "app/controllers/decidim/component/admin/application_controller.rb.erb", "#{app_folder}/controllers/decidim/#{component_name}/admin/application_controller.rb"
        template "app/helpers/decidim/component/application_helper.rb.erb", "#{app_folder}/helpers/decidim/#{component_name}/application_helper.rb"
        template "app/models/decidim/component/application_record.rb.erb", "#{app_folder}/models/decidim/#{component_name}/application_record.rb"

        bin_folder = "#{component_folder}/bin"
        template "bin/rails.erb", "#{bin_folder}/rails"
        chmod "#{bin_folder}/rails", "+x"

        config_folder = "#{component_folder}/config"
        template "config/assets.rb.erb", "#{config_folder}/assets.rb"
        template "config/locales/en.yml.erb", "#{config_folder}/locales/en.yml"
        template "config/i18n-tasks.yml.erb", "#{config_folder}/i18n-tasks.yml"

        lib_folder = "#{component_folder}/lib"
        template "lib/decidim/component.rb.erb", "#{lib_folder}/decidim/#{component_name}.rb"
        template "lib/decidim/component/engine.rb.erb", "#{lib_folder}/decidim/#{component_name}/engine.rb"
        template "lib/decidim/component/admin.rb.erb", "#{lib_folder}/decidim/#{component_name}/admin.rb"
        template "lib/decidim/component/admin_engine.rb.erb", "#{lib_folder}/decidim/#{component_name}/admin_engine.rb"
        template "lib/decidim/component/component.rb.erb", "#{lib_folder}/decidim/#{component_name}/component.rb"
        template "lib/decidim/component/version.rb.erb", "#{lib_folder}/decidim/#{component_name}/version.rb"
        template "lib/decidim/component/test/factories.rb.erb", "#{lib_folder}/decidim/#{component_name}/test/factories.rb"

        spec_folder = "#{component_folder}/spec"
        template "spec/spec_helper.rb.erb", "#{spec_folder}/spec_helper.rb"
        template "spec/factories.rb.erb", "#{spec_folder}/factories.rb"

        if options[:external]
          inside(component_folder) do
            Bundler.with_original_env { run "bundle install" }
          end
        end
      end

      private

      def format_email!
        begin
          raise "Security email must be defined" if @security_email.blank?
          return unless @security_email.include?("@")

          split = @security_email.split("@")
          email = split.first
          domain = split.last.gsub(".", " [dot] ")
          @security_email = "#{email} [at] #{domain}"
        rescue RuntimeError => e
          puts "[ERROR] #{e}"
          exit 1
        end
      end
    end
  end
end
