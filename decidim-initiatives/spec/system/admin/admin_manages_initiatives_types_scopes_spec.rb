# frozen_string_literal: true

require "spec_helper"

describe "Admin manages initiatives types scopes", type: :system do
  let(:organization) { create(:organization) }
  let(:user) { create(:user, :admin, :confirmed, organization: organization) }
  let(:initiatives_type) { create :initiatives_type, organization: organization }
  let!(:scope) { create :scope, organization: organization }

  before do
    switch_to_host(organization.host)
    login_as user, scope: :user
    visit decidim_admin_initiatives.edit_initiatives_type_path(initiatives_type)
  end

  context "when creating a new initiative type scope" do
    it "Creates a new initiative type scope" do
      click_link "New Initiative type scope"
      scope_pick select_data_picker(:initiatives_type_scope_decidim_scopes_id), scope
      fill_in :initiatives_type_scope_supports_required, with: 1000
      click_button "Create"

      within ".callout-wrapper" do
        expect(page).to have_content("A new scope for the given initiative type has been created")
      end
    end

    it "allows creating initiative type scopes with a Global scope" do
      click_link "New Initiative type scope"
      fill_in :initiatives_type_scope_supports_required, with: 10
      click_button "Create"

      within ".callout-wrapper" do
        expect(page).to have_content("A new scope for the given initiative type has been created")
      end

      within ".edit_initiative_type" do
        expect(page).to have_content("Global scope")
      end
    end
  end

  context "when editing an initiative type scope" do
    let!(:initiative_type_scope) { create :initiatives_type_scope, type: initiatives_type }

    before do
      visit decidim_admin_initiatives.edit_initiatives_type_path(initiatives_type)
    end

    it "updates the initiative type scope" do
      click_link "Configure"
      click_button "Update"
      within ".callout-wrapper" do
        expect(page).to have_content("The scope has been successfully updated")
      end
    end

    it "removes the initiative type scope" do
      click_link "Configure"
      accept_confirm { click_link "Delete" }
      within ".callout-wrapper" do
        expect(page).to have_content("The scope has been successfully removed")
      end
    end
  end
end
