# frozen_string_literal: true

require "spec_helper"

describe "Process admin manages proposals", type: :feature do
  let(:manifest_name) { "proposals" }
  let!(:proposal) { create :proposal, feature: current_feature }
  let!(:reportables) { create_list(:proposal, 3, feature: current_feature) }

  include_context "feature process admin"

  it_behaves_like "manage proposals"
  it_behaves_like "manage moderations"
  it_behaves_like "export proposals"
end
