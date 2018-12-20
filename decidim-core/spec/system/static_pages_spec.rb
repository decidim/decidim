# frozen_string_literal: true

require "spec_helper"

describe "Static pages", type: :system do
  let(:organization) { create(:organization) }
  let!(:page1) { create(:static_page, :with_topic, organization: organization) }
  let!(:page2) { create(:static_page, :with_topic, organization: organization) }
  let!(:page3) { create(:static_page, organization: organization) }

  before do
    switch_to_host(organization.host)
    visit decidim.pages_path
  end

  context "with standalone pages" do
    it "lists all the standalone pages" do
      within find(".row", text: "PAGES") do
        expect(page).to have_content translated(page3.title)
      end
    end
  end
end
