# frozen_string_literal: true

require "shakapacker"
require "shakapacker/runner"
require "decidim/webpacker"

Shakapacker::Runner.include(Decidim::Webpacker::Runner)
