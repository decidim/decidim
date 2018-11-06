# frozen_string_literal: true

require "spec_helper"

module Decidim::Budgets
  describe Project do
    it_behaves_like "project", :total_budget
    it_behaves_like "project", :total_projects
  end
end
