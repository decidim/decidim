# frozen_string_literal: true

require "spec_helper"

describe "Admin manages proposal answer templates", type: :system do
  let!(:organization) { create :organization }
  let!(:user) { create :user, :confirmed, organization: organization }

  before do
    switch_to_host(organization.host)
    login_as user, scope: :user
    visit decidim_admin_templates.proposal_answer_templates_path
  end

  describe "listing templates" do
    let!(:template) { create(:template, :proposal_answer, organization: organization) }

    before do
      visit decidim_admin_templates.proposal_answer_templates_path
    end

    it "shows a table with the templates info" do
      within ".questionnaire-templates" do
        expect(page).to have_i18n_content(template.name)
        expect(page).to have_i18n_content("Global scope")
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
      within ".new_proposal_answer_template" do
        fill_in_i18n(
          :proposal_answer_template_name,
          "#proposal_answer_template-name-tabs",
          en: "My template",
          es: "Mi plantilla",
          ca: "La meva plantilla"
        )
        fill_in_i18n(
          :proposal_answer_template_description,
          "#proposal_answer_template-description-tabs",
          en: "Description",
          es: "Descripción",
          ca: "Descripció"
        )

        choose "Not answered"

        page.find("*[type=submit]").click
      end

      expect(page).to have_admin_callout("successfully")
    end
  end

  describe "updating a template" do
    let!(:template) { create(:template, :proposal_answer, organization: organization) }

    before do
      visit decidim_admin_templates.proposal_answer_templates_path
      click_link translated(template.name)
    end

    it "updates a template" do
      fill_in_i18n(
        :proposal_answer_template_name,
        "#proposal_answer_template-name-tabs",
        en: "My new name",
        es: "Mi nuevo nombre",
        ca: "El meu nou nom"
      )

      within ".edit_proposal_answer_template" do
        page.find("*[type=submit]").click
      end

      expect(page).to have_admin_callout("successfully")

      within ".container" do
        expect(page).to have_current_path decidim_admin_templates.edit_proposal_answer_template_path(template)
        expect(page.find("#proposal_answer_template_name_en").value).to eq("My new name")
      end
    end
  end

  describe "updating a template with invalid values" do
    let!(:template) { create(:template, :proposal_answer, organization: organization) }

    before do
      visit decidim_admin_templates.proposal_answer_templates_path
      click_link translated(template.name)
    end

    it "does not update the template" do
      fill_in_i18n(
        :proposal_answer_template_name,
        "#proposal_answer_template-name-tabs",
        en: "",
        es: "",
        ca: ""
      )

      within ".edit_proposal_answer_template" do
        find("*[type=submit]").click
      end

      expect(page).to have_admin_callout("problem")
    end
  end

  describe "copying a template" do
    let!(:template) { create(:template, :proposal_answer, organization: organization) }

    before do
      visit decidim_admin_templates.proposal_answer_templates_path
    end

    it "copies the template" do
      within find("tr", text: translated(template.name)) do
        click_link "Duplicate"
      end

      expect(page).to have_admin_callout("successfully")
      expect(page).to have_content(template.name["en"], count: 2)
    end
  end

  describe "destroying a template" do
    let!(:template) { create(:template, :proposal_answer, organization: organization) }

    before do
      visit decidim_admin_templates.proposal_answer_templates_path
    end

    it "destroys the template" do
      within find("tr", text: translated(template.name)) do
        accept_confirm { click_link "Delete" }
      end

      expect(page).to have_admin_callout("successfully")
      expect(page).to have_no_i18n_content(template.name)
    end
  end
end
