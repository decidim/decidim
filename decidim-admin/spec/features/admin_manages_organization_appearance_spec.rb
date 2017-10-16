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
      visit decidim_admin.edit_organization_appearance_path

      fill_in_i18n_editor :organization_appearance_description,
                          "#organization_appearance-description-tabs",
                          en: "My own super description",
                          es: "Mi gran descripción",
                          ca: "La meva gran descripció"

      fill_in_i18n :organization_appearance_welcome_text,
                   "#organization_appearance-welcome_text-tabs",
                   en: "My super welcome text",
                   es: "Mi super texto de bienvenida",
                   ca: "El meu súper text de benvinguda"

      fill_in "Official organization URL", with: "http://www.example.com"

      attach_file "Homepage image", Decidim::Dev.asset("city.jpeg")
      attach_file "Logo", Decidim::Dev.asset("city2.jpeg")
      attach_file "Icon", Decidim::Dev.asset("city3.jpeg")
      attach_file "Official logo header", Decidim::Dev.asset("city2.jpeg")
      attach_file "Official logo footer", Decidim::Dev.asset("city3.jpeg")

      click_button "Update"

      expect(page).to have_content("updated successfully")
    end
  end
end
