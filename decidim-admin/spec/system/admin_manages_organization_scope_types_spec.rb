# frozen_string_literal: true

require "spec_helper"

describe "Admin manages scope types" do
  let(:admin) { create(:user, :admin, :confirmed) }
  let(:organization) { admin.organization }
  let!(:attributes) { attributes_for(:scope_type) }

  before do
    switch_to_host(organization.host)
    login_as admin, scope: :user
    visit decidim_admin.root_path
    click_link "Settings"
    click_link "Scopes"
    click_link "Scope types"
  end

  it "can create new scope types" do
    within ".card" do
      find(".new").click
    end

    within ".item__edit-form" do
      fill_in_i18n(
        :scope_type_name,
        "#scope_type-name-tabs",
        **attributes[:name].except("machine_translations")
      )

      fill_in_i18n(
        :scope_type_plural,
        "#scope_type-plural-tabs",
        **attributes[:plural].except("machine_translations")
      )

      find("*[type=submit]").click
    end

    expect(page).to have_admin_callout("successfully")

    within "table" do
      expect(page).to have_content(translated(attributes[:name]))
    end

    visit decidim_admin.root_path
    expect(page).to have_content("created the #{translated(attributes[:name])} scope type")
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

      within ".item__edit-form" do
        fill_in_i18n(
          :scope_type_name,
          "#scope_type-name-tabs",
          **attributes[:name].except("machine_translations")
        )

        fill_in_i18n(
          :scope_type_plural,
          "#scope_type-plural-tabs",
          **attributes[:plural].except("machine_translations")
        )
        find("*[type=submit]").click
      end

      expect(page).to have_admin_callout("successfully")

      within "table" do
        expect(page).to have_content(translated(attributes[:name]))
      end

      visit decidim_admin.root_path
      expect(page).to have_content("updated the #{translated(attributes[:name])} scope type")
    end

    it "can delete them" do
      within find("tr", text: translated(scope_type.name)) do
        accept_confirm { click_link "Delete" }
      end

      expect(page).to have_admin_callout("successfully")

      within "table" do
        expect(page).not_to have_content(translated(scope_type.name))
      end
    end
  end
end
