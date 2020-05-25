# frozen_string_literal: true

require "decidim/budgets/groups/workflows/base"
require "decidim/budgets/groups/workflows/one"
require "decidim/budgets/groups/workflows/random"
require "decidim/budgets/groups/workflows/all"

module Decidim
  module Budgets
    module Groups
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
end
