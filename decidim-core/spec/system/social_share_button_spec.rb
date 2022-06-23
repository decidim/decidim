# frozen_string_literal: true

require "spec_helper"

describe "Social share button", type: :system do
  let!(:resource) { create(:dummy_resource) }
  let(:resource_path) { Decidim::ResourceLocatorPresenter.new(resource).path }
  let(:web_driver) { :headless_chrome }

  before do
    driven_by(web_driver)
    switch_to_host(resource.organization.host)
  end

  shared_examples_for "showing the social share buttons" do
    it "shows the 'socialShare' modal" do
      within "#socialShare", visible: :visible do
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

  context "without cookie dialog" do
    before do
      page.driver.browser.execute_cdp(
        "Network.setCookie",
        domain: resource.organization.host,
        name: Decidim.consent_cookie_name,
        value: { essential: true }.to_json,
        path: "/"
      )
    end

    context "when the user is logged in" do
      before do
        sign_in resource.author
        visit resource_path
      end

      context "and clicks on the Share button" do
        before { click_button "Share" }

        it_behaves_like "showing the social share buttons"
      end
    end

    context "when the user is NOT logged in" do
      before { visit resource_path }

      context "and clicks on the Share button" do
        before { click_button "Share" }

        it_behaves_like "showing the social share buttons"
      end
    end
  end
end
