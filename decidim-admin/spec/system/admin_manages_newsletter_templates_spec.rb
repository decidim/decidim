# frozen_string_literal: true

require "spec_helper"

describe "Admin manages newsletter templates", type: :system do
  let(:organization) { create(:organization) }
  let(:user) { create(:user, :admin, :confirmed, name: "Sarah Kerrigan", organization: organization) }

  before do
    switch_to_host(organization.host)
    login_as user, scope: :user
  end

  describe "newsletter templates index" do
    let(:recipients_count) { deliverable_users.size }

    it "lists the available templates" do
      visit decidim_admin.newsletters_path

      within ".secondary-nav" do
        find(".button.new").click
      end

      expect(page).to have_content("Basic (only text)")
    end
  end

  describe "previewing a newsletter template" do
    it "allows the user to preview a template" do
      visit decidim_admin.newsletters_path

      within ".secondary-nav" do
        find(".button.new").click
      end

      click_link "Preview"

      expect(page).to have_content("PREVIEW TEMPLATE: BASIC (ONLY TEXT)")

      within_frame do
        expect(page).to have_content("body body body body")
      end
    end

    it "lets the user use the template to create a newsletter" do
      visit decidim_admin.newsletters_path

      within ".secondary-nav" do
        find(".button.new").click
      end

      click_link "Preview"

      click_link "Use this template"

      expect(page).to have_content("NEW NEWSLETTER")
    end
  end
end
