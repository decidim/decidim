# How to create a Decidim engine

## Standard way

1. Run the following command:

    ```
    rails plugin new decidim-<engine_name> --skip-gemfile --skip-test --skip-gemspec
    ```

1. Create a `decidim-<engine_name>.gemspec` file with this content:

    ```ruby
    # frozen_string_literal: true

    $LOAD_PATH.push File.expand_path("lib", __dir__)

    require_relative "../decidim-core/lib/decidim/core/version"

    Gem::Specification.new do |s|
      s.version = Decidim.version
      s.authors = ["Your Name"]
      s.email = ["your_eamail@example.org"]
      s.license = "AGPL-3.0"
      s.homepage = "https://github.com/decidim/decidim"
      s.required_ruby_version = ">= 2.3.1"

      s.name = "decidim-<engine_name>"
      s.summary = "<engine_description>"
      s.description = s.summary

      s.files = Dir["{app,config,db,lib,vendor}/**/*", "Rakefile", "README.md"]

      s.add_dependency "decidim-core", Decidim.version

      s.add_development_dependency "decidim-dev", Decidim.version
    end
    ```

1. Remove `bin/test` and add an executable `bin/rails` with this content:

    ```ruby
    #!/usr/bin/env ruby
    # frozen_string_literal: true

    # This command will automatically be run when you run "rails" with Rails gems
    # installed from the root of your application.

    ENGINE_ROOT = File.expand_path("..", __dir__)
    ENGINE_PATH = File.expand_path("../lib/decidim/<engine_name>/engine", __dir__)

    # Set up gems listed in the Gemfile.
    ENV["BUNDLE_GEMFILE"] ||= File.expand_path("../../Gemfile", __dir__)
    require "bundler/setup"

    require "rails/all"
    require "rails/engine/commands"
    ```

1. Replace `lib/decidim/<engine_name>.rb` with this:

    ```ruby
    # frozen_string_literal: true

    require "decidim/<engine_name>/engine"
    require "decidim/<engine_name>/feature"
    ```

1. Remove `lib/decidim/<engine_name>/version.rb`.

1. Remove `lib/tasks/decidim/<engine_name>_tasks.rb`.

1. Add `lib/decidim/<engine_name>/engine.rb` with this:

    ```ruby
    # frozen_string_literal: true

    require "rails"
    require "active_support/all"

    require "decidim/core"

    module Decidim
      module <EngineName>
        # Decidim's <EngineName> Rails Engine.
        class Engine < ::Rails::Engine
          isolate_namespace Decidim::<EngineName>

          initializer "decidim_<engine_name>.assets" do |app|
            app.config.assets.precompile += %w(decidim_<engine_name>_manifest.js)
          end
        end
      end
    end
    ```

1. Add `lib/decidim/<engine_name>/feature.rb` with this:

    ```ruby
    # frozen_string_literal: true

    Decidim.register_feature(:<engine_name>) do |feature|
      feature.engine = Decidim::<EngineName>::Engine
      feature.icon = "decidim/<engine_name>/icon.svg"

      feature.on(:before_destroy) do |instance|
        # Code executed before removing the feature
      end

      # These actions permissions can be configured in the admin panel
      feature.actions = %w()

      feature.settings(:global) do |settings|
        # Add your global settings
        # Available types: :integer, :boolean
        # settings.attribute :vote_limit, type: :integer, default: 0
      end

      feature.settings(:step) do |settings|
        # Add your settings per step
      end

      # # Register an optional resource that can be referenced from other resources.
      # feature.register_resource do |resource|
      #   resource.model_class_name = "Decidim::<EngineName>::<ResourceName>"
      #   resource.template = "decidim/<engine_name>/<resource_view_folder>/linked_<resource_name_plural>"
      # end

      feature.register_stat :some_stat do |features, start_at, end_at|
        # Register some stat number to the application
      end

      feature.seeds do |participatory_space|
        # Define seeds for a specific participatory_space object
      end
    end
    ```

1. Replace `Rakefile` with:

    ```ruby
    # frozen_string_literal: true

    require "decidim/common_rake"
    ```

1. Remove `MIT-LICENSE` and change `README`.

1. Add `spec/spec_helper.rb` with:

    ```ruby
    # frozen_string_literal: true

    require "decidim/dev"

    ENV["ENGINE_NAME"] = File.dirname(__dir__).split("/").last

    Decidim::Dev.dummy_app_path = File.expand_path(File.join("..", "spec", "decidim_dummy_app"))

    require "decidim/dev/test/base_spec_helper"
    ```

## Experimental way

Plugin creation is being automated in
[decidim-generators](https://github.com/codegram/decidim-generators). It's in an
early stage, but you might want to give it a try.
