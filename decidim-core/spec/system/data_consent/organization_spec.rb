# frozen_string_literal: true

require "spec_helper"

describe "Data consent within organization", type: :system do
  let(:organization) { create(:organization) }
  let(:cookie) { page.driver.browser.manage.cookie_named(Decidim.consent_cookie_name) }

  before do
    page.driver.browser.execute_cdp(
      "Network.deleteCookies",
      domain: ".#{organization.host}",
      name: Decidim.consent_cookie_name,
      path: "/"
    )

    switch_to_host(organization.host)
    visit decidim.root_path
  end

  it "shows the data consent" do
    expect(page).to have_content("Information about the cookies used on the website")
  end

  it "discards the data consent" do
    click_button(id: "cc-dialog-accept")
    expect(page).not_to have_content("Information about the cookies used on the website")
  end

  it "sets the correct expiration for the cookie" do
    diff = cookie[:expires].to_time - Time.zone.now
    expect(diff > 364.days).to be(true)
    expect(diff < 366.days).to be(true)
  end

  it "sets the correct domain for the cookie" do
    expect(cookie[:domain]).to eq(".#{organization.host}")
  end

  it "sets the correct SameSite flag for the cookie" do
    expect(cookie[:same_site]).to eq("Lax")
  end

  it "leaves HttpOnly flag false for the cookie" do
    # In order to expose the cookie to JS, this needs to be false. Otherwise it
    # is only available for the backend request headers.
    expect(cookie[:http_only]).to be(false)
  end

  if ENV["TEST_SSL"]
    it "sets the cookie with the secure flag" do
      expect(page).to have_content("Information about the cookies used on the website")
      click_button(id: "cc-dialog-accept")
      expect(cookie[:secure]).to be(true)
    end
  else
    it "sets the cookie without the secure flag" do
      expect(page).to have_content("Information about the cookies used on the website")
      click_button(id: "cc-dialog-accept")
      expect(cookie[:secure]).to be(false)
    end
  end
end
