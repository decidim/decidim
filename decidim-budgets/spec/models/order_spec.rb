# frozen_string_literal: true

require "spec_helper"

module Decidim::Budgets
  describe Order do
    it_behaves_like "order", :total_budget
    it_behaves_like "order", :total_projects
  end
end
