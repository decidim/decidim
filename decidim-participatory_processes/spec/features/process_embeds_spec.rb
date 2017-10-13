# frozen_string_literal: true

require "spec_helper"

describe "Process embeds", type: :feature do
  let!(:process) { create(:participatory_process) }

  context "when visiting the embed page for a process" do
    before do
      switch_to_host(process.organization.host)
      visit resource_locator(process).path
      visit "#{current_path}/embed"
    end

    it "renders the page correctly" do
      expect(page).to have_i18n_content(process.title)
      expect(page).to have_content(process.organization.name)
    end
  end
end
