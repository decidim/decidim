# frozen_string_literal: true

require "spec_helper"
describe "Admin manages external domain list" do
  let!(:admin) { create(:user, :admin, :confirmed, organization:) }

  before do
    switch_to_host(organization.host)
    login_as admin, scope: :user
    visit decidim_admin.edit_organization_external_domain_allowlist_path
  end

  context "when there are items in allowed list" do
    let(:organization) { create(:organization, external_domain_allowlist: ["example.org", "twitter.com", "facebook.com", "youtube.com", "github.com", "mytesturl.me"]) }

    it "displays all the allowed domains in the list" do
      inputs = page.all(".external-domains-list input[type=text]")
      expect(inputs.count).to eq(6)
    end

    it "removes items from the allowed domain list" do
      buttons = page.all(".external-domains-list button.remove-external-domain")

      within ".external-domains-list" do
        buttons[0].click
      end

      click_on "Update"

      organization.reload
      expect(organization.external_domain_allowlist).not_to include("example.org")
    end

    it "reorders the elements in the list" do
      within ".external-domains-list" do
        all("button.move-down-question")[0].click
        all("button.move-up-question")[2].click # there are 6 elements in the list, but only 5 buttons of "move up", first element is on the second input
        all("button.move-down-question")[4].click # there are 6 elements in the list, but only 5 buttons of "move down", last element is on the 5th input
      end

      click_on "Update"
      organization.reload
      expect(organization.external_domain_allowlist).to eq(["twitter.com", "example.org", "youtube.com", "facebook.com", "mytesturl.me", "github.com"])
    end
  end

  context "when there are no items in allowed list" do
    let(:organization) { create(:organization, external_domain_allowlist: []) }

    it "updates the external domains list" do
      expect(page).to have_content("Add to allowed list")
      click_on "Add to allowed list"
      within ".external-domains-list" do
        find(:css, "input[type=text]").set("example.org")
      end

      click_on "Update"

      organization.reload
      expect(organization.external_domain_allowlist).to include("example.org")
    end

    it "updates the list when having multiple allowed domains" do
      expect(page).to have_content("Add to allowed list")
      click_on "Add to allowed list"
      click_on "Add to allowed list"

      inputs = page.all(".external-domains-list input[type=text]")
      within ".external-domains-list" do
        inputs[0].set("example.org")
        inputs[1].set("decidim.org")
      end

      click_on "Update"

      organization.reload
      expect(organization.external_domain_allowlist).to include("example.org", "decidim.org")
    end

    it "reorders the list" do
      expect(page).to have_content("Add to allowed list")
      click_on "Add to allowed list"
      click_on "Add to allowed list"

      within ".external-domains-list" do
        expect(page).to have_css("input[type=text]", count: 2)
        second_input = all("input[type=text]")[1]
        all("input[type=text]")[0].set("example.org")
        all("button.move-down-question")[0].click
        second_input.set("decidim.org")
      end

      click_on "Update"

      organization.reload
      expect(organization.external_domain_allowlist).to eq(["decidim.org", "example.org"])
    end
  end
end
