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

      attr_reader :component_name, :component_module_name, :component_resource_name, :component_folder, :component_description, :core_version

      source_root File.expand_path("component_templates", __dir__)

      desc "component COMPONENT_NAME", "Generate a decidim component"

      method_options destination_folder: :string, external: :boolean

      def component(component_name)
        @component_name = component_name
        @component_module_name = component_name.camelize
        @component_folder = options[:destination_folder] || "decidim-module-#{component_name}"
        @core_version = Decidim::Core.version
        @component_description = ask "Write a description for the new component:"

        template "decidim-component.gemspec.erb", "#{component_folder}/decidim-#{component_name}.gemspec"
        template "Gemfile.erb", "#{component_folder}/Gemfile" if options[:external]
        template "Rakefile", "#{component_folder}/Rakefile"
        template "LICENSE-AGPLv3.txt", "#{component_folder}/LICENSE-AGPLv3.txt"
        template "README.md.erb", "#{component_folder}/README.md"
        template "gitignore", "#{component_folder}/.gitignore"
        template "circleci/config.yml", "#{component_folder}/.circleci/config.yml"

        app_folder = "#{component_folder}/app"
        template "app/assets/config/component_manifest.js", "#{app_folder}/assets/config/decidim_#{component_name}_manifest.js"
        template "app/assets/images/decidim/component/icon.svg", "#{app_folder}/assets/images/decidim/#{component_name}/icon.svg"
        template "app/controllers/decidim/component/application_controller.rb.erb", "#{app_folder}/controllers/decidim/#{component_name}/application_controller.rb"
        template "app/controllers/decidim/component/admin/application_controller.rb.erb", "#{app_folder}/controllers/decidim/#{component_name}/admin/application_controller.rb"
        template "app/helpers/decidim/component/application_helper.rb.erb", "#{app_folder}/helpers/decidim/#{component_name}/application_helper.rb"
        template "app/models/decidim/component/application_record.rb.erb", "#{app_folder}/models/decidim/#{component_name}/application_record.rb"

        bin_folder = "#{component_folder}/bin"
        template "bin/rails.erb", "#{bin_folder}/rails"
        chmod "#{bin_folder}/rails", "+x"

        config_folder = "#{component_folder}/config"
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
    end
  end
end
