# frozen_string_literal: true

require "spec_helper"

describe "AdminContentSuggestions" do
  include_context "with a component"
  let(:manifest_name) { "proposals" }
  let(:current_user) { create(:user, :admin, :confirmed) }
  let(:organization) { current_user.organization }
  let(:participatory_space) { create(:participatory_process, organization:, title: { en: "My space" }) }

  before do
    switch_to_host(organization.host)
    login_as current_user, scope: :user
    visit decidim_admin.root_path
    click_on "Processes"
    click_link_or_button "My space"
    click_link_or_button "Component"
  end

  context "when updating proposal component" do
    it "with content suggestions enabled" do
      click_link_or_button "Configure"

      within "div#panel-global_settings" do
        find_by_id("component_settings_content_suggestions_enabled").set(true)
        find_by_id("component_settings_content_suggestions_limit").set(8)
        find_by_id("component_settings_content_suggestions_criteria_location").click
      end

      click_link_or_button "Update"

      within ".flash__message" do
        expect(page).to have_content("The component was updated successfully.")
      end

      click_link_or_button "Configure"

      within "div#panel-global_settings" do
        expect(find_by_id("component_settings_content_suggestions_enabled")).to be_checked
        expect(find_by_id("component_settings_content_suggestions_limit").value).to eq("8")
        expect(find_by_id("component_settings_content_suggestions_criteria_location").checked?).to be(true)
      end

      proposal_component = participatory_space.components.first
      proposal_component.reload

      expect(proposal_component.settings["content_suggestions_enabled"]).to be(true)
      expect(proposal_component.settings["content_suggestions_limit"]).to eq(8)
      expect(proposal_component.settings["content_suggestions_criteria"]).to eq("location")
    end

    it "with content suggestions disabled" do
      click_link_or_button "Configure"

      within "div#panel-global_settings" do
        find_by_id("component_settings_content_suggestions_enabled").set(false)
      end

      click_link_or_button "Update"

      within ".flash__message" do
        expect(page).to have_content("The component was updated successfully.")
      end

      click_link_or_button "Configure"

      within "div#panel-global_settings" do
        expect(find_by_id("component_settings_content_suggestions_enabled")).not_to be_checked
      end

      proposal_component = participatory_space.components.first
      proposal_component.reload

      expect(proposal_component.settings["content_suggestions_enabled"]).to be(false)
    end
  end

  context "when accessing a component form" do
    it "displays the content suggestions fields correctly with default values" do
      click_link_or_button "Configure"

      within "div#panel-global_settings" do
        expect(find_by_id("component_settings_content_suggestions_enabled")).not_to be_checked
        expect(page).to have_field("component_settings_content_suggestions_limit")
        expect(find_by_id("component_settings_content_suggestions_limit").value).to eq(Decidim::Proposals.default_content_suggestions_limit.to_s)
        within "div.content_suggestions_criteria_container" do
          expect(page).to have_css("label[for='component_settings_content_suggestions_criteria_location']")
          expect(page).to have_css("label[for='component_settings_content_suggestions_criteria_random']")
          expect(page).to have_css("label[for='component_settings_content_suggestions_criteria_most_recent']")
          expect(page).to have_css("label[for='component_settings_content_suggestions_criteria_taxonomy']")
        end
      end
    end
  end
end
