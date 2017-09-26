# frozen_string_literal: true

require "spec_helper"

describe "Assembly embeds", type: :feature do
  let!(:assembly) { create(:assembly) }

  context "when visiting the embed page for an assembly" do
    before do
      switch_to_host(assembly.organization.host)
      visit resource_locator(assembly).path
      visit "#{current_path}/embed"
    end

    it "renders the page correctly" do
      expect(page).to have_i18n_content(assembly.title)
      expect(page).to have_content(assembly.organization.name)
    end
  end
end
