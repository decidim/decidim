# frozen_string_literal: true

require "spec_helper"
require "rack/attack"

describe "Access list", type: :system do
  let!(:organization) { create(:organization) }
  let!(:admin) { create(:admin) }

  before do
    switch_to_host(organization.host)
    login_as admin, scope: :admin
  end

  it "allows access to citizen side" do
    visit decidim.root_path

    expect(page).to have_content(organization.name)
  end

  it "allows access to admin side page" do
    visit decidim_system.root_path

    expect(page).to have_content("Dashboard")
  end

  context "when an access list has been specified" do
    before do
      allow(Decidim.config).to receive(:system_accesslist_ips).and_return(["127.0.0.1"])
    end

    it "allows access to citizen side" do
      visit decidim.root_path

      expect(page).to have_content(organization.name)
    end

    it "allows access to admin side page" do
      visit decidim_system.root_path

      expect(page).not_to have_content("Dashboard")
      expect(page).to have_content("Forbidden")
    end
  end
end
