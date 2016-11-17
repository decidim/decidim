# coding: utf-8
# frozen_string_literal: true

require "spec_helper"

describe "Admin manages ogranization", type: :feature do
  let(:organization) { create(:organization) }
  let(:user) { create(:user, :admin, :confirmed, organization: organization) }

  before do
    switch_to_host(organization.host)
    login_as user, scope: :user
    visit decidim_admin.organization_path
  end

  describe "show" do
    it "lists the details from the organization" do
      within ".main-content" do
        expect(page).to have_content(organization.name)
        expect(page.body).to include(translated(organization.description))
        expect(page.body).to include(translated(organization.description, locale: :es))
        expect(page.body).to include(translated(organization.description, locale: :ca))
      end
    end
  end

  describe "edit" do
    it "updates the values from the form" do
      click_link "Edit"

      fill_in "Name", with: "My super-uber organization"
      fill_in_i18n_editor :organization_description, "#description-tabs", {
        en: "My own super description",
        es: "Mi gran descripción",
        ca: "La meva gran descripció"
      }

      click_button "Update organization"

      expect(page).to have_content("updated successfully")

      expect(page).to have_content("My super-uber organization")
      expect(page).to have_content("My own super description")
      expect(page).to have_content("Mi gran descripción")
      expect(page).to have_content("La meva gran descripció")
    end
  end
end
