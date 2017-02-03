# frozen_string_literal: true

require "spec_helper"

describe "Process admin manages proposals", type: :feature do
  include_context "admin"
  let(:user) { process_admin }
  it_behaves_like "manage proposals"
  include_context "feature"
  let(:manifest_name) { "proposals" }

  before do
    switch_to_host(organization.host)
    login_as user, scope: :user
    visit decidim_admin.manage_feature_path(participatory_process_id: participatory_process, feature_id: current_feature)
  end
end
