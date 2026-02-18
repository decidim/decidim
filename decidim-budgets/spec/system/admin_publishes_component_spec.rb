# frozen_string_literal: true

require "spec_helper"

describe "Admin publishes component" do
  let(:manifest_name) { "budgets" }

  context "with a budget" do
    let!(:resource) { create(:budget, component:) }

    include_context "when publishing and unpublishing the component"
    include_context "when cycling through publication states"
  end

  context "with a project" do
    let!(:budget) { create(:budget, component:) }
    let!(:resource) { create(:project, budget:) }

    include_context "when publishing and unpublishing the component"
    include_context "when cycling through publication states"
  end
end
