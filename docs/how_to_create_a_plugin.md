# How to create a Decidim engine

## Standard way

1. Run the following command:

    ```
    rails plugin new decidim-<engine_name> --skip-gemfile --skip-test --skip-gemspec
    ```

1. Create a `decidim-<engine_name>.gemspec` file with this content:

    ```ruby
    # frozen_string_literal: true
    $LOAD_PATH.push File.expand_path("../lib", __FILE__)

    require_relative "../decidim-core/lib/decidim/core/version"

    Gem::Specification.new do |s|
      Decidim.add_default_gemspec_properties(s)

      s.name        = "decidim-<engine_name>"
      s.summary     = "<engine_description>"
      s.description = s.summary

      s.files = Dir["{app,config,db,lib,vendor}/**/*", "Rakefile", "README.md"]

      s.add_dependency "decidim-core", Decidim.version
      s.add_dependency "rails", *Decidim.rails_version

      s.add_development_dependency "decidim-dev", Decidim.version
    end
    ```

1. Remove `bin/test` and add `bin/rails` with this content:

    ```ruby
    #!/usr/bin/env ruby
    # frozen_string_literal: true
    # This command will automatically be run when you run "rails" with Rails gems
    # installed from the root of your application.

    ENGINE_ROOT = File.expand_path("../..", __FILE__)
    ENGINE_PATH = File.expand_path("../../lib/decidim/<engine_name>/engine", __FILE__)

    # Set up gems listed in the Gemfile.
    ENV["BUNDLE_GEMFILE"] ||= File.expand_path("../../Gemfile", __FILE__)
    require "bundler/setup" if File.exist?(ENV["BUNDLE_GEMFILE"])

    require "rails/all"
    require "rails/engine/commands"
    ```

1. Replace `lib/decidim/<engine_name>.rb` with this:

    ```ruby
    # frozen_string_literal: true
    require "decidim/<engine_name>/engine"
    ```

1. Remove `lib/decidim/<engine_name>/version.rb`

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

    require_dependency "decidim/features/namer"

    Decidim.register_feature(:<engine_name>) do |feature|
      feature.engine = Decidim::<EngineName>::Engine
      feature.admin_engine = Decidim::<EngineName>::AdminEngine
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

      feature.register_resource do |resource|
        # Register a optional resource that can be references from other resources.
        # resource.model_class_name = "Decidim::<EngineName>::<ResourceName>"
        # resource.template = "decidim/<engine_name>/<resource_view_folder>/linked_<resource_name_plural>"
      end

      feature.register_stat :some_stat do |features, start_at, end_at|
        # Register some stat number to the application
      end

      feature.seeds do
        # Add some seeds for this feature
      end
    end
    ```

1. Replace `Rakefile` with:

    ```ruby
    # frozen_string_literal: true
    require "decidim/common_rake"
    ```

1. Remove `MIT-LICENSE` and change `README`

1. Add `spec/spec_helper.rb` with:

    ```ruby
    # frozen_string_literal: true
    ENV["ENGINE_NAME"] = File.dirname(File.dirname(__FILE__)).split("/").last
    require "decidim/test/base_spec_helper"
    ```

## Experimental way

Plugin creation is being automated in
[decidim-generators](https://github.com/codegram/decidim-generators). It's in an
early stage, but you might want to give it a try.
