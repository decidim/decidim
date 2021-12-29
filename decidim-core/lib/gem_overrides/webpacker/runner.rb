# frozen_string_literal: true

# This file overrides the webpacker/runner require in order to customize the
# runner when it is started.

require "#{Gem.loaded_specs["webpacker"].full_gem_path}/lib/webpacker/runner"
require "decidim/webpacker"

Webpacker::Runner.include(Decidim::Webpacker::Runner)
