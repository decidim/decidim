# frozen_string_literal: true

require "spec_helper"

describe "Admin manages templates", type: :system do
  let!(:organization) { create :organization }
  let!(:user) { create :user, organization: organization }

  before do
    switch_to_host(organization.host)
    login_as user, scope: :user
    visit decidim_admin_templates.questionnaire_templates_path
  end

  describe "creating a template" do
    before do
      within ".layout-content" do
        click_link("New")
      end
    end

    let(:template) { Decidim::Templates::Template.last }

    it "creates a new template with a questionnaire as templatable" do
      within ".new_questionnaire_template" do
        fill_in_i18n(
          :template_name,
          "#template-name-tabs",
          en: "My template",
          es: "Mi plantilla",
          ca: "La meva plantilla"
        )
        fill_in_i18n(
          :template_description,
          "#template-description-tabs",
          en: "Description",
          es: "Descripción",
          ca: "Descripció"
        )

        find("*[type=submit]").click
      end

      expect(page).to have_admin_callout("successfully")

      within ".container" do
        expect(page).to have_current_path decidim_admin_templates.questionnaire_templates_path
        expect(page).to have_content("My template")
      end
    end
  end
end
