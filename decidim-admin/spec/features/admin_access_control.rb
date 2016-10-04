# frozen_string_literal: true
require "spec_helper"

describe "Admin dashboard access control", type: :feature do
  let(:organization) { create(:organization) }

  before do
    switch_to_host(organization.host)
  end

  context "when authenticated" do
    before do
      login_as user, scope: :user
    end

    context "a regular user" do
      let(:user) { create(:user, organization: organization) }

      it "can't access the admin dashboard" do
        visit decidim_admin.root_path
        expect(page.status_code).to eq(404)
      end
    end

    context "an organization admin" do
      let(:user) { create(:user, :admin, organization: organization) }

      it "can access the admin dashboard" do
        visit decidim_admin.root_path
        expect(page.status_code).to eq(200)
        expect(page).to have_content("Dashboard")
      end
    end

    context "an admin from another organization" do
      let(:other_organization) { create(:organization) }
      let(:user) { create(:user, :admin, organization: other_organization) }

      it "can't access the admin dashboard" do
        visit decidim_admin.root_path
        expect(page.status_code).to eq(404)
      end
    end
  end

  describe "when unauthenticated" do
    it "can't access the admin dashboard" do
      visit decidim_admin.root_path
      expect(page.body).to include("You need to sign in")
    end
  end
end
