# frozen_string_literal: true

require "decidim/engine"
require "decidim/core"
require "decidim/system"
require "decidim/admin"
require "decidim/api"
require "decidim/version"

require "decidim/forms"

require "decidim/verifications"

require "decidim/participatory_processes"
require "decidim/assemblies"

require "decidim/pages"
require "decidim/comments"
require "decidim/meetings"
require "decidim/proposals"
require "decidim/budgets"
require "decidim/surveys"
require "decidim/accountability"
require "decidim/debates"
require "decidim/sortitions"
require "decidim/blogs"

# Module declaration.
module Decidim
  # Declare a Webpacker instance for Decidim
  ROOT_PATH = Pathname.new(File.join(__dir__, ".."))

  class << self
    def webpacker
      @webpacker ||= ::Webpacker::Instance.new(
        root_path: ROOT_PATH,
        config_path: ROOT_PATH.join("config/webpacker.yml")
      )
    end
    def webpacker_gem_instance
      @webpacker_gem_instance ||= ::Webpacker::Instance.new(
        root_path: Pathname.new(File.join(Gem.loaded_specs['decidim'].full_gem_path)),
        # root_path: ROOT_PATH,
        config_path: ROOT_PATH.join("config/webpacker_gem_instance.yml")
      )
    end

    def with_decidim_webpacker_instance
      original_instance = Webpacker.instance
      Webpacker.instance = self.webpacker_gem_instance
      yield(self.webpacker, original_instance)
    ensure
      Webpacker.instance = original_instance
    end
  end
end
