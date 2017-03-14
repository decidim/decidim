# frozen_string_literal: true

require "spec_helper"

describe "Manage admins", type: :feature do
  let(:admin) { create(:admin) }
  let!(:admin2) { create(:admin) }

  before do
    login_as admin, scope: :admin
    visit decidim_system.admins_path
  end

  it "creates a new admin" do
    find(".actions .new").click

    within ".new_admin" do
      fill_in :admin_email, with: "admin@foo.bar"
      fill_in :admin_password, with: "fake123"
      fill_in :admin_password_confirmation, with: "fake123"

      find("*[type=submit]").click
    end

    within ".callout-wrapper" do
      expect(page).to have_content("successfully")
    end

    within "table" do
      expect(page).to have_content("admin@foo.bar")
    end
  end

  it "updates an admin" do
    within find("tr", text: admin.email) do
      click_link "Edit"
    end

    within ".edit_admin" do
      fill_in :admin_email, with: "admin@another.domain"

      find("*[type=submit]").click
    end

    within ".callout-wrapper" do
      expect(page).to have_content("successfully")
    end

    within "table" do
      expect(page).to have_content("admin@another.domain")
    end
  end

  it "deletes an admin" do
    within find("tr", text: admin2.email) do
      click_link "Destroy"
    end

    within ".callout-wrapper" do
      expect(page).to have_content("successfully")
    end

    within "table" do
      expect(page).not_to have_content(admin2.email)
    end
  end
end
