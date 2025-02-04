# frozen_string_literal: true

require "decidim/generators/version"

module Decidim
  module Generators
    def self.edge_git_branch
      if Decidim::Generators.version.match?(/\.dev$/)
        "feature/new-collaborative_texts-module" # back to "develop" once https://github.com/decidim/decidim/pull/13978 is accepted
      else
        "release/#{Decidim::Generators.version.match(/^[0-9]+\.[0-9]+/)[0]}-stable"
      end
    end
  end
end
