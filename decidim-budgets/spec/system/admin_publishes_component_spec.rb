# frozen_string_literal: true

require "spec_helper"

describe "Admin publishes component" do
  let(:manifest_name) { "budgets" }

  contexts "with a budget" do
    let!(:resource) { create(:budget, component:) }
    include_context "when publishes and unpublishes component"
  end

  context "with a project" do
    let!(:budget) { create(:budget, component:) }
    let!(:resource) { create(:project, budget:) }

    include_context "when publishes and unpublishes component"
  end
end
