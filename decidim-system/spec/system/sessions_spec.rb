# frozen_string_literal: true

require "spec_helper"

describe "Sessions", type: :system do
  let!(:admin) do
    create(:admin, email: "admin@example.org",
                   password: "123456",
                   password_confirmation: "123456")
  end

  before do
    visit decidim_system.root_path
  end

  context "when using a correct username and password" do
    it "lets you into the system panel" do
      within ".new_admin" do
        fill_in :admin_email, with: "admin@example.org"
        fill_in :admin_password, with: "123456"
        find("*[type=submit]").click
      end

      expect(page).to have_content("Dashboard")
    end
  end

  context "when using an incorrect username and password" do
    it "doesn't let you in the admin panel" do
      within ".new_admin" do
        fill_in :admin_email, with: "admin@example.org"
        fill_in :admin_password, with: "forged_password"
        find("*[type=submit]").click
      end

      expect(page).to have_no_content("Dashboard")
    end
  end
end
