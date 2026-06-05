# frozen_string_literal: true

require "spec_helper"

describe "Restricted Space Debate" do
  let(:manifest_name) { "debates" }
  let(:manifest) { Decidim.find_component_manifest(manifest_name) }

  let!(:organization) { create(:organization) }
  let(:user) { create(:user, :confirmed, organization:) }
  let!(:other_user) { create(:user, :confirmed, organization:) }
  let!(:member) { create(:member, user: other_user, participatory_space:) }

  let!(:participatory_space) { create(:assembly, :published, :restricted, organization:) }
  let!(:component) { create(:component, manifest:, participatory_space:) }

  before do
    switch_to_host(organization.host)
    component.update!(default_step_settings: { creation_enabled: true })
  end

  context "when the user is not logged in" do
    let(:target_path) { main_component_path(component) }

    before do
      visit target_path
    end

    it "disallows the access" do
      expect(page).to have_text("You are not authorized to perform this action")
    end
  end

  context "when the user is logged in" do
    context "and is member space" do
      before do
        login_as other_user, scope: :user
      end

      it "allows create a debate" do
        page.visit main_component_path(component)

        click_on "New debate"

        within ".new_debate" do
          fill_in :debate_title, with: "Creating my debate"
          fill_in :debate_description, with: "This is my debate's description and I am using it unwisely."

          find("*[type=submit]").click
        end

        expect(page).to have_text("Debate successfully created.")
      end
    end

    context "and is not member space" do
      let(:target_path) { main_component_path(component) }

      before do
        login_as user, scope: :user
        visit target_path
      end

      it "disallows the access" do
        expect(page).to have_text("You are not authorized to perform this action")
      end
    end
  end
end
