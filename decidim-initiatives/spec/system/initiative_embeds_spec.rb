# frozen_string_literal: true

require "spec_helper"

describe "Initiative embeds", type: :system do
  let!(:initiative) { create(:initiative) }

  context "when visiting the embed page for an initiative" do
    before do
      switch_to_host(initiative.organization.host)
      visit resource_locator(initiative).path
      visit "#{current_path}/embed"
    end

    it "renders the page correctly" do
      expect(page).to have_i18n_content(initiative.title)
      expect(page).to have_content(initiative.organization.name)
    end
  end
end
