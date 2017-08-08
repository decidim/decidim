# frozen_string_literal: true

require "spec_helper"

describe "Process admin manages projects", type: :feature do
  let(:manifest_name) { "budgets" }
  let!(:project) { create :project, scope: scope, feature: current_feature }

  include_context "feature process admin"

  it_behaves_like "manage projects"
  it_behaves_like "manage announcements"
end
