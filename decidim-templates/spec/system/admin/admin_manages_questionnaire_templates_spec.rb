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
  
  describe "listing templates" do
    let!(:template) { create(:questionnaire_template, organization: organization) }

    before do
      visit decidim_admin_templates.questionnaire_templates_path
    end

    it "shows a table with the templates info" do
      within ".questionnaire-templates" do
        expect(page).to have_content(template.name["en"])
        expect(page).to have_content(template.templatable.title["en"])
      end
    end
  end
  
  describe "creating a questionnaire_template" do
    before do
      within ".layout-content" do
        click_link("New")
      end
    end

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

  describe "trying to create a questionnaire_template with invalid data" do
    before do
      within ".layout-content" do
        click_link("New")
      end
    end

    it "fails to create a new questionnaire_template" do
      within ".new_questionnaire_template" do
        fill_in_i18n(
          :template_name,
          "#template-name-tabs",
          en: "",
          es: "",
          ca: ""
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

      expect(page).to have_admin_callout("problem")
    end
  end
  
  describe "updating a template" do
    let!(:template) { create(:questionnaire_template, organization: organization) }

    before do
      visit decidim_admin_templates.questionnaire_templates_path
      click_link translated(template.name)
    end

    it "updates a template" do
      fill_in_i18n(
        :template_name,
        "#template-name-tabs",
        en: "My new name",
        es: "Mi nuevo nombre",
        ca: "El meu nou nom"
      )

      within ".edit_questionnaire_template" do
        find("*[type=submit]").click
      end

      expect(page).to have_admin_callout("successfully")

      within ".container" do
        expect(page).to have_content("My new name")
      end
    end
  end
  
  describe "updating a template with invalid values" do
    let!(:template) { create(:questionnaire_template, organization: organization) }

    before do
      visit decidim_admin_templates.questionnaire_templates_path
      click_link translated(template.name)
    end

    it "does not update the template" do
      fill_in_i18n(
        :template_name,
        "#template-name-tabs",
        en: "",
        es: "",
        ca: ""
      )

      within ".edit_questionnaire_template" do
        find("*[type=submit]").click
      end

      expect(page).to have_admin_callout("problem")
    end
  end

  describe "editing the questionnaire_template's questionnaire" do
    let!(:template) { create(:questionnaire_template, organization: organization) }

    before do
      visit decidim_admin_templates.questionnaire_templates_path
    end
    
    it "shows a functional questionnaire form" do
      within ".layout-content" do
        click_link("Edit")
      end
  
      within ".container" do
        click_link("Edit")
      end

      within ".edit_questionnaire" do
        fill_in_i18n(
          :questionnaire_title,
          "#questionnaire-title-tabs",
          en: "My questionnaire",
          es: "Mi formulario",
          ca: "El meu formulari"
        )

        fill_in_i18n_editor(
          :questionnaire_tos,
          "#questionnaire-tos-tabs",
          en: "My terms",
          es: "Mis términos",
          ca: "Els meus termes"
        )

        click_button "Add question"
        find(".button.expand-all").click

        within ".questionnaire-question" do
          find("[id$=body_en]").fill_in(with: "My question")
        end

        find("*[type=submit]").click
      end

      expect(page).to have_admin_callout("successfully")

      within ".container" do
        expect(page).to have_current_path decidim_admin_templates.edit_questionnaire_template_path(template)
        expect(page).to have_content("My question")
      end
    end
  end
end
