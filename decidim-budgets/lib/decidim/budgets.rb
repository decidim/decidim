# frozen_string_literal: true

require "decidim/budgets/workflows"
require "decidim/budgets/admin"
require "decidim/budgets/api"
require "decidim/budgets/engine"
require "decidim/budgets/admin_engine"
require "decidim/budgets/component"

module Decidim
  # Base module for this engine.
  module Budgets
    autoload :ProjectSerializer, "decidim/budgets/project_serializer"
  end
end
