# frozen_string_literal: true

require "spec_helper"

describe "Conference embeds", type: :system do
  let!(:conference) { create(:conference) }

  context "when visiting the embed page for an conference" do
    before do
      switch_to_host(conference.organization.host)
      visit resource_locator(conference).path
      visit "#{current_path}/embed"
    end

    it "renders the page correctly" do
      expect(page).to have_i18n_content(conference.title)
      expect(page).to have_content(conference.organization.name)
    end
  end
end
