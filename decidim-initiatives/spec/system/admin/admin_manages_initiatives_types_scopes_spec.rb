# frozen_string_literal: true

require "spec_helper"

describe "Admin manages initiatives types scopes" do
  let(:organization) { create(:organization) }
  let(:user) { create(:user, :admin, :confirmed, organization:) }
  let(:initiatives_type) { create(:initiatives_type, organization:) }
  let!(:scope) { create(:scope, organization:) }

  before do
    switch_to_host(organization.host)
    login_as user, scope: :user
    visit decidim_admin_initiatives.edit_initiatives_type_path(initiatives_type)
  end

  context "when creating a new initiative type scope" do
    it "Creates a new initiative type scope" do
      click_on "New initiative type scope"
      select translated(scope.name), from: :initiatives_type_scope_decidim_scopes_id
      fill_in :initiatives_type_scope_supports_required, with: 1000
      click_on "Create"

      expect(page).to have_admin_callout("A new scope for the given initiative type has been created")
    end

    it "allows creating initiative type scopes with a Global scope" do
      click_on "New initiative type scope"
      fill_in :initiatives_type_scope_supports_required, with: 10
      click_on "Create"

      expect(page).to have_admin_callout("A new scope for the given initiative type has been created")

      within ".edit_initiative_type" do
        expect(page).to have_content("Global scope")
      end
    end
  end

  context "when editing an initiative type scope" do
    let!(:initiative_type_scope) { create(:initiatives_type_scope, type: initiatives_type) }

    before do
      visit decidim_admin_initiatives.edit_initiatives_type_path(initiatives_type)
    end

    it "updates the initiative type scope" do
      within "#panel-initiative_type_scope tr", text: translated_attribute(initiative_type_scope.scope_name) do
        find("button[data-component='dropdown']").click
        click_on "Configure"
      end
      click_on "Update"

      expect(page).to have_admin_callout("The scope has been successfully updated")
    end
  end
end
