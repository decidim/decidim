# frozen_string_literal: true

require "spec_helper"

describe "Process admin manages projects", type: :feature do
  let(:user) { process_admin }
  let(:manifest_name) { "budgets" }
  let!(:project) { create :project, scope: scope, feature: current_feature }

  include_context "admin"

  it_behaves_like "manage projects"
end
