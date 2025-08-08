# frozen_string_literal: true

require "spec_helper"

describe "Documentation" do
  let(:organization) { create(:organization) }

  before do
    switch_to_host(organization.host)
  end

  describe "documentation" do
    before do
      # Should be the default but can be affected by ENV vars
      allow(Decidim::Api).to receive(:disclose_system_version).and_return(false)
    end

    it "shows the project's documentation" do
      visit decidim_api.documentation_path

      within "h1" do
        expect(page).to have_content(translated(organization.name))
      end
      expect(page).to have_content("About the GraphQL API")
    end

    it "does not disclose system version by default" do
      visit decidim_api.documentation_path
      expect(page).to have_no_css(".content .version")
      expect(page).to have_no_content("Decidim #{Decidim.version}")
    end

    context "when version disclosure is enabled" do
      it "discloses the system version" do
        allow(Decidim::Api).to receive(:disclose_system_version).and_return(true)

        visit decidim_api.documentation_path
        expect(page).to have_css(".content .version")
        expect(find(".content .version").text).to eq("Decidim #{Decidim.version}")
      end
    end
  end
end
