# frozen_string_literal: true

require "spec_helper"

describe "AdminAccess" do
  let(:manifest_name) { "budgets" }
  let(:budget) { create(:budget, component:) }
  let!(:project) { create(:project, budget:) }

  include_context "when publishes and unpublishes component"
end
