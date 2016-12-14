# coding: utf-8
# frozen_string_literal: true

require "spec_helper"

describe "Admin manages ogranization", type: :feature do
  let(:organization) { create(:organization) }
  let(:user) { create(:user, :admin, :confirmed, organization: organization) }

  before do
    switch_to_host(organization.host)
    login_as user, scope: :user
  end

  describe "edit" do
    it "updates the values from the form" do
      visit decidim_admin.edit_organization_path

      fill_in "Name", with: "My super-uber organization"

      fill_in_i18n_editor :organization_description, "#description-tabs", {
        en: "My own super description",
        es: "Mi gran descripción",
        ca: "La meva gran descripció"
      }

      fill_in_i18n :organization_welcome_text, "#welcome_text-tabs", {
        en: "My super welcome text",
        es: "Mi super texto de bienvenida",
        ca: "El meu súper text de benvinguda"
      }

      click_button "Update organization"

      expect(page).to have_content("updated successfully")
    end
  end
end
