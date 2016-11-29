# coding: utf-8
# frozen_string_literal: true
require "spec_helper"

describe "Components can be navigated", type: :feature do
  include_context "component"

  let(:feature_manifest) { Decidim.find_feature_manifest("dummy") }
  let(:component_manifest) { Decidim.find_component_manifest("dummy") }

  describe "navigate to a component" do
    before do
      visit decidim.participatory_process_path(participatory_process)
    end

    it "renders the content of the page" do
      within ".process-nav" do
        click_link component.name[I18n.locale]
      end

      expect(page).to have_content("DUMMY ENGINE")
    end
  end
end
