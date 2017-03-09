# frozen_string_literal: true

require "spec_helper"

describe "Admin manages proposals", type: :feature do
  include_context "admin"
  it_behaves_like "manage proposals"
  it_behaves_like "manage moderations"
  include_context "feature"
  let(:manifest_name) { "proposals" }

  let!(:reportables) { create_list(:proposal, 3, feature: current_feature) }

  before do
    switch_to_host(organization.host)
    login_as user, scope: :user
    visit decidim_admin.manage_feature_path(participatory_process_id: participatory_process, feature_id: current_feature)
  end
end
