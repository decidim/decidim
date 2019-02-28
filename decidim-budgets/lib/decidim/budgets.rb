# frozen_string_literal: true

require "decidim/budgets/admin"
require "decidim/budgets/engine"
require "decidim/budgets/admin_engine"
require "decidim/budgets/component"

module Decidim
  # Base module for this engine.
  module Budgets
  end
  module ContentParsers
    autoload :ProjectParser, "decidim/content_parsers/project_parser"
  end

  module ContentRenderers
    autoload :ProjectRenderer, "decidim/content_renderers/project_renderer"
  end
end
