# frozen_string_literal: true

require "spec_helper"

describe "Footer" do
  let(:organization) { create(:organization) }

  context "when on a large viewport (accordion disabled)" do
    before do
      switch_to_host(organization.host)
      visit decidim.root_path
    end

    it "shows all footer panels by default" do
      within "footer" do
        %w(panel-footer-menu panel-profile panel-resources panel-help).each do |panel_id|
          expect(page).to have_css("##{panel_id}[aria-hidden='false']")
        end
      end
    end

    it "renders footer accordion triggers as buttons with the expected markup" do
      within "footer" do
        %w(panel-footer-menu-trigger panel-profile-trigger panel-resources-trigger panel-help-trigger).each do |trigger_id|
          trigger = find("##{trigger_id}")
          expect(trigger.tag_name).to eq("button")
          expect(trigger[:type]).to eq("button")
          expect(trigger).to have_css(".h4")
        end
      end
    end

    it "does not allow pointer events on accordion triggers" do
      within "footer" do
        %w(panel-footer-menu-trigger panel-profile-trigger panel-resources-trigger panel-help-trigger).each do |trigger_id|
          trigger = find("##{trigger_id}")
          pointer_events = page.evaluate_script("window.getComputedStyle(arguments[0]).pointerEvents", trigger.native)
          expect(pointer_events).to eq("none")
        end
      end
    end
  end

  context "when on a small viewport (accordion enabled)" do
    before do
      driven_by(:iphone)
      switch_to_host(organization.host)
      visit decidim.root_path
      click_on(id: "dc-dialog-accept")
    end

    it "hides all footer panels by default" do
      within "footer" do
        %w(panel-footer-menu panel-profile panel-resources panel-help).each do |panel_id|
          expect(page).to have_css("##{panel_id}[aria-hidden='true']", visible: :all)
        end
      end
    end

    it "expands a panel when its trigger is clicked" do
      within "footer" do
        find_by_id("panel-footer-menu-trigger").click
        expect(page).to have_css("#panel-footer-menu[aria-hidden='false']")
      end
    end

    it "collapses a panel when its trigger is clicked again" do
      within "footer" do
        find_by_id("panel-footer-menu-trigger").click
        expect(page).to have_css("#panel-footer-menu[aria-hidden='false']")

        find_by_id("panel-footer-menu-trigger").click
        expect(page).to have_css("#panel-footer-menu[aria-hidden='true']", visible: :all)
      end
    end
  end
end
