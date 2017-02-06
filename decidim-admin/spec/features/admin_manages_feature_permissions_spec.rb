# frozen_string_literal: true
require "spec_helper"

describe "Admin a feature's permissions", type: :feature do
  let(:organization) { create(:organization) }
  let(:user) { create(:user, :admin, :confirmed, organization: organization) }

  let!(:participatory_process) do
    create(:participatory_process, :with_steps, organization: organization)
  end

  let!(:feature) do
    create(:feature, participatory_process: participatory_process)
  end

  before do
    switch_to_host(organization.host)
    login_as user, scope: :user
    visit decidim_admin.participatory_process_features_path(participatory_process)

    within ".feature-#{feature.id}" do
      click_link "Permissions"
    end
  end

  it "whatever" do
    screenshot_and_open_image
  end
end
