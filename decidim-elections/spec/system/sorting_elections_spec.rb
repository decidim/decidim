# frozen_string_literal: true

require "spec_helper"

describe "Sorting elections", type: :system do
  include_context "with a component"
  let(:manifest_name) { "elections" }

  let(:organization) { create :organization }
  let!(:user) { create :user, :confirmed, organization: }
  let!(:election1) { create :election, :complete, :published, :ongoing, component:, start_time: 1.day.ago }
  let!(:election2) { create :election, :complete, :published, :ongoing, component:, start_time: 2.days.ago }

  before do
    switch_to_host(organization.host)
    login_as user, scope: :user
  end

  context "when ordering by recent" do
    it "lists the elections in desc start_time order" do
      visit_component
      within ".order-by" do
        expect(page).to have_selector("ul[data-dropdown-menu$=dropdown-menu]", text: "Recent")
      end

      expect(page).to have_selector("#elections .card-grid .column:first-child", text: translated(election1.title))
      expect(page).to have_selector("#elections .card-grid .column:last-child", text: translated(election2.title))
    end
  end

  context "when ordering by older" do
    it "lists the elections in asc start_time order" do
      visit_component
      within ".order-by" do
        expect(page).to have_selector("ul[data-dropdown-menu$=dropdown-menu]", text: "Recent")
        page.find("a", text: "Recent").click
        click_link "Older"
      end

      expect(page).to have_selector("#elections .card-grid .column:first-child", text: translated(election2.title))
      expect(page).to have_selector("#elections .card-grid .column:last-child", text: translated(election1.title))
    end
  end
end
