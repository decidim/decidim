# frozen_string_literal: true

require "spec_helper"
require "rack/attack"

describe "Access list", type: :system do
  let!(:organization) { create(:organization) }

  before do
    switch_to_host(organization.host)
    login_as user, scope: scope
  end

  context "when logged as admin" do
    let!(:user) { create(:user, :admin, :confirmed, organization: organization) }
    let(:scope) { :user }

    it "allows access to participants side" do
      visit decidim.root_path

      expect(page).to have_content(organization.name)
    end

    it "allows access to admin side" do
      visit decidim_admin.root_path

      expect(page).to have_content("Dashboard")
    end

    context "when an access list to admin has been specified" do
      before do
        allow(Decidim.config).to receive(:admin_accesslist_ips).and_return(["127.0.0.1"])
      end

      it "allows access to participants side" do
        visit decidim.root_path

        expect(page).to have_content(organization.name)
      end

      it "allows access to admin side page" do
        visit decidim_admin.root_path

        expect(page).not_to have_content("Dashboard")
        expect(page).to have_content("Forbidden")
      end
    end
  end

  context "when logged as system admin" do
    let!(:user) { create(:admin) }
    let(:scope) { :admin }

    it "allows access to participants side" do
      visit decidim.root_path

      expect(page).to have_content(organization.name)
    end

    it "allows access to admin side" do
      visit decidim_system.root_path

      expect(page).to have_content("Dashboard")
    end

    context "when an access list to system has been specified" do
      before do
        allow(Decidim.config).to receive(:system_accesslist_ips).and_return(["127.0.0.1"])
      end

      it "allows access to participants side" do
        visit decidim.root_path

        expect(page).to have_content(organization.name)
      end

      it "allows access to system side page" do
        visit decidim_system.root_path

        expect(page).not_to have_content("Dashboard")
        expect(page).to have_content("Forbidden")
      end
    end
  end
end
