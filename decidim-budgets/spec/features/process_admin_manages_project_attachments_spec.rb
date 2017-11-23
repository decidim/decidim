# frozen_string_literal: true

require "spec_helper"

describe "Process admin manages project attachments", type: :feature do
  let(:manifest_name) { "budgets" }
  let!(:project) { create :project, scope: scope, feature: current_feature }

  include_context "when managing a feature as a process admin"

  it_behaves_like "manage project attachments"
end
