# frozen_string_literal: true

require "spec_helper"

describe "Documentation", type: :system do
  let(:organization) { create(:organization) }

  before do
    switch_to_host(organization.host)
  end

  describe "documentation" do
    it "shows the project's documentation" do
      visit decidim_api.documentation_path

      within "h1" do
        expect(page).to have_content(organization.name)
      end

      within ".info" do
        expect(page).to have_content("ABOUT THE GRAPHQL API")
      end
    end
  end
end
