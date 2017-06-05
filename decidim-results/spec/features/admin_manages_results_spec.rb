# frozen_string_literal: true

require "spec_helper"

describe "Admin manages results", type: :feature do
  let(:manifest_name) { "results" }
  let!(:result) { create :result, scope: scope, feature: current_feature }

  include_context "admin"

  it_behaves_like "manage results"
end
