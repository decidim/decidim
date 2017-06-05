# frozen_string_literal: true

require "spec_helper"

describe "Admin manages project attachments", type: :feature do
  let(:manifest_name) { "budgets" }
  let!(:project) { create :project, scope: scope, feature: current_feature }

  include_context "admin"

  it_behaves_like "manage project attachments"
end
