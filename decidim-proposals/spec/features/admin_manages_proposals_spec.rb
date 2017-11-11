# frozen_string_literal: true

require "spec_helper"

describe "Admin manages proposals", type: :feature do
  let(:manifest_name) { "proposals" }
  let!(:proposal) { create :proposal, feature: current_feature }
  let!(:reportables) { create_list(:proposal, 3, feature: current_feature) }

  include_context "when managing a feature as an admin"

  it_behaves_like "manage proposals"
  it_behaves_like "manage moderations"
  it_behaves_like "export proposals"
  it_behaves_like "manage announcements"
  it_behaves_like "manage proposals help texts"
end
