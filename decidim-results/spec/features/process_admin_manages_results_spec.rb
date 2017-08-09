# frozen_string_literal: true

require "spec_helper"

describe "Process admin manages results", type: :feature do
  let(:manifest_name) { "results" }
  let!(:result) { create :result, scope: scope, feature: current_feature }

  include_context "feature process admin"

  it_behaves_like "manage results"
  it_behaves_like "manage announcements"
end
