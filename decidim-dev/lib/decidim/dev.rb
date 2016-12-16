# frozen_string_literal: true
require "decidim/dev/assets"

module Decidim
  # Decidim::Dev holds all the convenience logic and libraries to be able to
  # create external libraries that create test apps and test themselves against
  # them.
  module Dev
    # Public: Finds an asset.
    #
    # Returns a String with the path for a particular asset.
    def self.asset(name)
      File.join(
        File.dirname(__FILE__),
        "dev",
        "assets",
        name
      )
    end
  end
end
