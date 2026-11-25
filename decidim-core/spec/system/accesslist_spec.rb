# frozen_string_literal: true

require "spec_helper"
require "rack/attack"

describe "Access list" do
  let!(:organization) { create(:organization) }
  let!(:admin) { create(:admin) }

  before do
    switch_to_host(organization.host)
    login_as admin, scope: :admin
  end

  it "allows access to participants side" do
    visit decidim.root_path

    expect(page).to have_text(translated(organization.name))
  end

  it "allows access to admin side page" do
    visit decidim_system.root_path

    expect(page).to have_text("Dashboard")
  end

  context "when an access list has been specified" do
    before do
      allow(Decidim.config).to receive(:system_accesslist_ips).and_return(["127.0.0.1"])
    end

    it "allows access to participants side" do
      visit decidim.root_path

      expect(page).to have_text(translated(organization.name))
    end

    it "allows access to the system from an IP in the access list" do
      # Capybara requests reach the app from 127.0.0.1, the listed address
      visit decidim_system.root_path

      expect(page).to have_text("Dashboard")
    end
  end

  context "when an access list has been specified without the request IP" do
    before do
      allow(Decidim.config).to receive(:system_accesslist_ips).and_return(["10.0.0.1"])
    end

    it "allows access to participants side" do
      visit decidim.root_path

      expect(page).to have_text(translated(organization.name))
    end

    it "blocks access to the system from an IP outside the access list" do
      # The access list is an allow-list, so the request from an address that is
      # not in it is the one that gets denied
      visit decidim_system.root_path

      expect(page).to have_no_text("Dashboard")
      expect(page).to have_text("Forbidden")
    end
  end
end
