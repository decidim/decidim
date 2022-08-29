# frozen_string_literal: true

require "spec_helper"

describe "Admin manages scope types", type: :system do
  let(:admin) { create :user, :admin, :confirmed }
  let(:organization) { admin.organization }

  before do
    switch_to_host(organization.host)
    login_as admin, scope: :user
    visit decidim_admin.root_path
    click_link "Settings"
    click_link "Scope types"
  end

  it "can create new scope types" do
    within ".card" do
      find(".new").click
    end

    within ".new_scope_type" do
      fill_in_i18n(
        :scope_type_name,
        "#scope_type-name-tabs",
        en: "Territorial en",
        es: "Territorial es",
        ca: "Territorial ca"
      )

      fill_in_i18n(
        :scope_type_plural,
        "#scope_type-plural-tabs",
        en: "Territorials en",
        es: "Territoriales es",
        ca: "Territorials ca"
      )

      find("*[type=submit]").click
    end

    expect(page).to have_admin_callout("successfully")

    within "table" do
      expect(page).to have_content("Territorial en")
    end
  end

  context "with existing scope_types" do
    let!(:scope_type) { create(:scope_type, organization:) }

    before do
      visit current_path
    end

    it "lists all the scope types for the organization" do
      within "#scope-types table" do
        expect(page).to have_content(translated(scope_type.name, locale: :en))
      end
    end

    it "can edit them" do
      within find("tr", text: translated(scope_type.name)) do
        click_link "Edit"
      end

      within ".edit_scope_type" do
        fill_in_i18n(
          :scope_type_name,
          "#scope_type-name-tabs",
          en: "Not Territorial en"
        )

        fill_in_i18n(
          :scope_type_plural,
          "#scope_type-plural-tabs",
          en: "This is the new pluarl"
        )
        find("*[type=submit]").click
      end

      expect(page).to have_admin_callout("successfully")

      within "table" do
        expect(page).to have_content("Not Territorial en")
      end
    end

    it "can delete them" do
      within find("tr", text: translated(scope_type.name)) do
        accept_confirm { click_link "Delete" }
      end

      expect(page).to have_admin_callout("successfully")

      within "table" do
        expect(page).to have_no_content(translated(scope_type.name))
      end
    end
  end
end
