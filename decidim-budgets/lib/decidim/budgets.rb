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
    autoload :OrderPDF, "decidim/budgets/budget_order_pdf"

    include ActiveSupport::Configurable

    # Public Setting that defines whether proposals can be linked to meetings
    config_accessor :enable_proposal_linking do
      Decidim::Env.new("BUDGETS_ENABLE_PROPOSAL_LINKING", Decidim.const_defined?("Proposals")).present?
    end
  end
end
