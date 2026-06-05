# frozen_string_literal: true

require "shakapacker"
require "shakapacker/runner"
require "decidim/shakapacker"
require "decidim/webpacker"

Shakapacker::Runner.include(Decidim::Shakapacker::Runner)
