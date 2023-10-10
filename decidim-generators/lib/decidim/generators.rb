# frozen_string_literal: true
$LOAD_PATH.unshift "#{Gem.loaded_specs["decidim-core"].full_gem_path}/lib/gem_overrides"

require "decidim/generators/version"

module Decidim
  module Generators
    def self.edge_git_branch
      if Decidim::Generators.version.match?(/\.dev$/)
        "chore/upgrade-shakapacker"
      else
        "release/#{Decidim::Generators.version.match(/^[0-9]+\.[0-9]+/)[0]}-stable"
      end
    end
  end
end
