# frozen_string_literal: true

require "spec_helper"

describe "Admin manages area types", type: :system do
  let(:admin) { create :user, :admin, :confirmed }
  let(:organization) { admin.organization }

  before do
    switch_to_host(organization.host)
    login_as admin, scope: :user
    visit decidim_admin.root_path
    click_link "Settings"
    click_link "Area types"
  end

  it "can create new area types" do
    within ".card" do
      find(".new").click
    end

    within ".new_area_type" do
      fill_in_i18n(
        :area_type_name,
        "#area_type-name-tabs",
        en: "Sectorial en",
        es: "Sectorial es",
        ca: "Sectorial ca"
      )

      fill_in_i18n(
        :area_type_plural,
        "#area_type-plural-tabs",
        en: "Sectorials en",
        es: "Sectoriales es",
        ca: "Sectorials ca"
      )

      find("*[type=submit]").click
    end

    expect(page).to have_admin_callout("successfully")

    within "table" do
      expect(page).to have_content("Sectorial en")
    end
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
      within find("tr", text: translated(area_type.name)) do
        click_link "Edit"
      end

      within ".edit_area_type" do
        fill_in_i18n(
          :area_type_name,
          "#area_type-name-tabs",
          en: "Not Sectorial en"
        )

        fill_in_i18n(
          :area_type_plural,
          "#area_type-plural-tabs",
          en: "This is the new pluarl"
        )
        find("*[type=submit]").click
      end

      expect(page).to have_admin_callout("successfully")

      within "table" do
        expect(page).to have_content("Not Sectorial en")
      end
    end

    it "can delete them" do
      within find("tr", text: translated(area_type.name)) do
        accept_confirm { click_link "Delete" }
      end

      expect(page).to have_admin_callout("successfully")

      within "table" do
        expect(page).to have_no_content(translated(area_type.name))
      end
    end
  end
end
