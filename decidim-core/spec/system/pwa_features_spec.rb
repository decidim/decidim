# frozen_string_literal: true

require "spec_helper"

describe "PWA features", type: :system do
  let(:organization) { create(:organization, host: "pwa.lvh.me") }

  before do
    driven_by(:pwa_chrome)
    switch_to_host(organization.host)
  end

  describe "offline navigation" do
    it "shows the account form when clicking on the menu" do
      # Cache the homepage
      visit decidim.root_path
      expect(page).to have_content("Home")

      page.driver.browser.network_conditions = { offline: true }

      # Wait for the browser to be offline
      sleep 1

      visit decidim.root_path
      expect(page).to have_content("Home")
      expect(page).to have_content("Your network is offline. This is a previously cached version of the page you're visiting, perhaps the content is not up to date.")

      # Restore the network conditions
      page.driver.browser.network_conditions = { offline: false }
    end
  end
end
