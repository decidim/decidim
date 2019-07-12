# frozen_string_literal: true

require "spec_helper"

describe "Social share button", type: :system do
  let!(:resource) { create(:dummy_resource) }
  let(:user) { create(:user, :confirmed, organization: resource.organization) }
  let(:resource_path) { Decidim::ResourceLocatorPresenter.new(resource).path }
  let(:web_driver) { :headless_chrome }

  before do
    driven_by(web_driver)
    switch_to_host(resource.organization.host)
    sign_in user
    visit resource_path
  end

  context "when clicking on the Share button" do
    before do
      click_button "Share"
    end

    it "shows the Share modal" do
      within "#socialShare", visible: true do
        expect(page).to have_css("h3", text: "Share:")
        expect(page).to have_css(".social-share-button")
      end
    end

    it "shows the 'Share to Twitter' button" do
      within ".social-share-button" do
        expect(page).to have_css('a[data-site="twitter"]')
      end
    end

    it "shows the 'Share to Facebook' button" do
      within ".social-share-button" do
        expect(page).to have_css('a[data-site="facebook"]')
      end
    end

    it "shows the 'Share to Telegram' button" do
      within ".social-share-button" do
        expect(page).to have_css('a[data-site="telegram"]')
      end
    end

    context "when the device is a desktop" do
      it "shows the desktop version of 'Share to Whatsapp' button" do
        within ".social-share-button" do
          expect(page).to have_css('a[data-site="whatsapp_web"]')
        end
      end

      it "hides the mobile version of 'Share to Whatsapp' button" do
        within ".social-share-button" do
          expect(page).not_to have_css('a[data-site="whatsapp_app"]')
        end
      end
    end

    context "when the device is a mobile" do
      let(:web_driver) { :iphone }

      it "shows the mobile version of 'Share to Whatsapp' button" do
        within ".social-share-button" do
          expect(page).to have_css('a[data-site="whatsapp_app"]')
        end
      end

      it "hides the desktop version of 'Share to Whatsapp' button" do
        within ".social-share-button" do
          expect(page).not_to have_css('a[data-site="whatsapp_web"]')
        end
      end
    end
  end
end
