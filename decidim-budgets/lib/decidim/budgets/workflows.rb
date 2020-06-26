# frozen_string_literal: true

require "decidim/budgets/workflows/base"
require "decidim/budgets/workflows/one"
require "decidim/budgets/workflows/random"
require "decidim/budgets/workflows/all"

module Decidim
  module Budgets
    # Public: Stores the array of available workflows
    def self.workflows
      @workflows ||= {
        one: Workflows::One,
        random: Workflows::Random,
        all: Workflows::All
      }
    end
  end
end
