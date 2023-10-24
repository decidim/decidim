# frozen_string_literal: true

# This file overrides the webpacker/runner require in order to customize the
# runner when it is started.

require "#{Gem.loaded_specs["shakapacker"].full_gem_path}/lib/shakapacker/runner"
require "decidim/webpacker"

Shakapacker::Runner.include(Decidim::Webpacker::Runner)
