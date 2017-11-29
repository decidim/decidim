# frozen_string_literal: true

require "decidim/core"
require "decidim/system"
require "decidim/admin"
require "decidim/api"
require "decidim/version"

require "decidim/verifications"

require "decidim/participatory_processes"

begin
  require "decidim/assemblies"
rescue LoadError
  nil
end

require "decidim/pages"
require "decidim/comments"
require "decidim/meetings"
require "decidim/proposals"
require "decidim/budgets"
require "decidim/surveys"
require "decidim/accountability"

# Module declaration.
module Decidim
end
