# frozen_string_literal: true

require "spec_helper"

describe "Admin manages area types" do
  let(:admin) { create(:user, :admin, :confirmed) }
  let(:organization) { admin.organization }
  let(:attributes) { attributes_for(:area_type) }

  before do
    switch_to_host(organization.host)
    login_as admin, scope: :user
    visit decidim_admin.root_path
    click_on "Settings"
    click_on "Areas"
    click_on "Area types"
  end

  it "can create new area types" do
    within ".card" do
      find(".new").click
    end

    within ".new_area_type" do
      fill_in_i18n(
        :area_type_name,
        "#area_type-name-tabs",
        **attributes[:name].except("machine_translations")
      )

      fill_in_i18n(
        :area_type_plural,
        "#area_type-plural-tabs",
        **attributes[:plural].except("machine_translations")
      )

      find("*[type=submit]").click
    end

    expect(page).to have_admin_callout("successfully")

    within "table" do
      expect(page).to have_content(translated(attributes[:name]))
    end

    visit decidim_admin.root_path
    expect(page).to have_content("created the #{translated(attributes[:name])} area type")
  end

  context "with existing area_types" do
    let!(:area_type) { create(:area_type, organization:) }

    before do
      visit current_path
    end

    it "lists all the area types for the organization" do
      within "#area-types table" do
        expect(page).to have_content(translated(area_type.name, locale: :en))
      end
    end

    it "can edit them" do
      within "tr", text: translated(area_type.name) do
        find("button[data-component='dropdown']").click
        click_on "Edit"
      end

      within ".edit_area_type" do
        fill_in_i18n(
          :area_type_name,
          "#area_type-name-tabs",
          **attributes[:name].except("machine_translations")
        )

        fill_in_i18n(
          :area_type_plural,
          "#area_type-plural-tabs",
          **attributes[:plural].except("machine_translations")
        )
        find("*[type=submit]").click
      end

      expect(page).to have_admin_callout("successfully")

      within "table" do
        expect(page).to have_content(translated(attributes[:name]))
      end

      visit decidim_admin.root_path
      expect(page).to have_content("updated the #{translated(attributes[:name])} area type")
    end

    it "can delete them" do
      within "tr", text: translated(area_type.name) do
        find("button[data-component='dropdown']").click
        accept_confirm { click_on "Delete" }
      end

      expect(page).to have_admin_callout("successfully")

      within "table" do
        expect(page).to have_no_content(translated(area_type.name))
      end
    end
  end
end
