# How to create a Decidim engine

1. Run the following command:
```bash
- rails plugin new decidim-<engine_name>
```

2. Change the `decidim-<engine_name>.gemspec` file:

> Change this:

```ruby
$:.push File.expand_path("../lib", __FILE__)
```

> Into this:

```ruby
# frozen_string_literal: true
$LOAD_PATH.push File.expand_path("../lib", __FILE__)
```

---

> Change this:

```ruby
require "decidim/<engine_name>/version"
```

> Into this:

```ruby
require_relative "../decidim-core/lib/decidim/core/version"
```

---

> Add this:

```ruby
Gem::Specification.new do |s|
  Decidim.add_default_gemspec_properties(s)

  s.files = Dir["{app,config,db,lib,vendor}/**/*", "Rakefile", "README.md"]
```

---

> Remove this:

```ruby
s.version     = Decidim::<EngineName>::VERSION
s.authors     = [""]
s.email       = [""]
s.homepage    = "TODO"
s.license     = "MIT"
```

---

> Add this:

```ruby
s.add_dependency "decidim-core", Decidim.version
```

---

> Remove this:

```ruby
s.add_dependency "rails", "~> 5.0.0", ">= 5.0.0.1"
s.add_development_dependency "sqlite3"
```

> And add this instead:

```ruby
s.add_dependency "rails", *Decidim.rails_version
s.add_development_dependency "decidim-dev", Decidim.version
```

---

> Add more dependencies as needed:

```ruby
s.add_dependency "foundation-rails", "~> 6.2.4.0"
s.add_dependency "autoprefixer-rails", ["~> 6.7", ">= 6.7.4"]
s.add_dependency "sass-rails", "~> 5.0.0"
s.add_dependency "jquery-rails", "~> 4.0"
s.add_dependency "foundation_rails_helper", "~> 2.0.0"
```

---

3. Replace `Gemfile` content with this:

```ruby
source 'https://rubygems.org'

gem 'decidim', path: '..'
gemspec

eval(File.read(File.join(File.dirname(__FILE__), "..", "Gemfile.common")))
```

4. Remove `test` folder

5. Remove `bin/test` and add `bin/rails` with this content:

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

6. Change `lib/decidim/<engine_name>.rb`

> Add this

```ruby
# frozen_string_literal: true
require "decidim/<engine_name>/engine"
```

7. Remove `lib/decidim/<engine_name>/version.rb`

8. Add `lib/decidim/<engine_name>/engine.rb` with this:

```ruby
# frozen_string_literal: true
require "rails"
require "active_support/all"

require "decidim/core"
require "jquery-rails"
require "sass-rails"
require "foundation-rails"
require "foundation_rails_helper"
require "autoprefixer-rails"

module Decidim
  module <EngineName>
    # Decidim's core Rails Engine.
    class Engine < ::Rails::Engine
      isolate_namespace Decidim::<EngineName>

      initializer "decidim_<engine_name>.assets" do |app|
        app.config.assets.precompile += %w(decidim_<engine_name>_manifest.js)
      end
    end
  end
end
```

9. Add `lib/decidim/<engine_name>/feature.rb` with this:

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

10. Replace `Rakefile` with:

```ruby
# frozen_string_literal: true
require "decidim/common_rake"
```

11. Remove `MIT-LICENSE` and change `README`

12. Add `spec/spec_helper.rb` with:

```ruby
ENV["ENGINE_NAME"] = File.dirname(File.dirname(__FILE__)).split("/").last
require "decidim/test/base_spec_helper"
```
