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

module Decidim
  class << self
    def webpacker
      @webpacker ||= ::Webpacker::Instance.new(
        root_path: Decidim::Engine.root,
        config_path: Rails.root.join("config/decidim_webpacker.yml")
      )
    end
  end
end
