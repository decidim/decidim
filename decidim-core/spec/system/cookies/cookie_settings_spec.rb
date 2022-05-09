# frozen_string_literal: true

require "spec_helper"

describe "Cookies", type: :system do
  let(:orga) { create(:organization) }
  let(:cookies_description) { "We use cookies on our website to improve the performance and content of the site" }

  before do
    switch_to_host(orga.host)
    visit decidim.root_path
  end

  describe "cookie dialog" do
    it "user see the cookie policy" do
      within "#cc-dialog-wrapper" do
        expect(page).to have_content "Information about the cookies used on the website"
      end
    end

    it "user accepts the cookies and dialog isn't shown anymore'" do
      expect(page).to have_content(cookies_description)

      click_button "Accept all"
      expect(page).not_to have_content(cookies_description)

      visit decidim.root_path
      expect(page).not_to have_content(cookies_description)
    end

    it "user rejects the cookies and dialog isn't shown anymore'" do
      expect(page).to have_content(cookies_description)

      click_button "Essential only"
      expect(page).not_to have_content(cookies_description)

      visit decidim.root_path
      expect(page).not_to have_content(cookies_description)
    end
  end

  describe "cookie modal" do
    it "modal remembers users selection" do
      within "#cc-dialog-wrapper" do
        click_button "Settings"
      end

      within "[data-id='analytics']" do
        find(".switch-paddle").click
      end
      click_button "Save settings"

      within ".mini-footer" do
        click_link "Cookie settings"
      end

      within "[data-id='analytics']" do
        expect(find("input", visible: :all).checked?).to be(true)
      end
      within "[data-id='marketing']" do
        expect(find("input", visible: :all).checked?).to be(false)
      end
      within "[data-id='preferences']" do
        expect(find("input", visible: :all).checked?).to be(false)
      end
    end
  end
end
