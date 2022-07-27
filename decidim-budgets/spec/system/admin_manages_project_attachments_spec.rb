# frozen_string_literal: true

require "spec_helper"

describe "Admin manages project attachments", type: :system do
  let(:manifest_name) { "budgets" }
  let(:budget) { create :budget, component: current_component }
  let!(:project) { create :project, budget: }

  include_context "when managing a component as an admin"

  it_behaves_like "manage project attachments"
end
