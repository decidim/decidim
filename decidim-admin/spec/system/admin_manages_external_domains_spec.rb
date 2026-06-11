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
      page.execute_script(
        <<~JS
          const firstField = document.querySelector(".external-domains-list .external-domain");
          if (!firstField) return;

          const deletedInput = firstField.querySelector('input[name$="[deleted]"]');
          if (deletedInput) deletedInput.value = "true";

          firstField.classList.add("hidden");
          firstField.style.display = "none";
        JS
      )

      click_on "Update"

      organization.reload
      expect(organization.external_domain_allowlist).not_to include("example.org")
    end

    it "reorders the elements in the list" do
      page.execute_script(
        <<~JS
          const desiredOrder = [
            "twitter.com",
            "example.org",
            "youtube.com",
            "facebook.com",
            "mytesturl.me",
            "github.com"
          ];

          const list = document.querySelector(".external-domains-list");
          if (!list) return;

          desiredOrder.forEach((domain) => {
            const field = Array.from(list.querySelectorAll(".external-domain")).find((item) => {
              const valueInput = item.querySelector('input[type="text"]');
              return valueInput && valueInput.value === domain;
            });

            if (field) list.appendChild(field);
          });
        JS
      )

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
        expect(page).to have_field("input[type=text]", count: 2)
        all("input[type=text]")[0].set("example.org")
        all("input[type=text]")[1].set("decidim.org")
      end

      page.execute_script(
        <<~JS
          const desiredOrder = ["decidim.org", "example.org"];
          const list = document.querySelector(".external-domains-list");
          if (!list) return;

          desiredOrder.forEach((domain) => {
            const field = Array.from(list.querySelectorAll(".external-domain")).find((item) => {
              const valueInput = item.querySelector('input[type="text"]');
              return valueInput && valueInput.value === domain;
            });

            if (field) list.appendChild(field);
          });
        JS
      )

      click_on "Update"

      organization.reload
      expect(organization.external_domain_allowlist).to eq(["decidim.org", "example.org"])
    end
  end
end
