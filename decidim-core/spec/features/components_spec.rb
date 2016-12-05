# coding: utf-8
# frozen_string_literal: true
require "spec_helper"

describe "Features can be navigated", type: :feature do
  include_context "feature"

  let(:manifest_name) { "dummy" }

  describe "navigate to a component" do
    before do
      visit decidim.participatory_process_path(participatory_process)
    end

    it "renders the content of the page" do
      within ".process-nav" do
        click_link feature.name[I18n.locale]
      end

      expect(page).to have_content("DUMMY ENGINE")
    end
  end
end
