# frozen_string_literal: true

require "spec_helper"
require "decidim/proposals/test/factories"

describe "Admin manages proposal answer templates", type: :system do
  let!(:organization) { create(:organization) }
  let!(:user) { create(:user, :admin, :confirmed, organization:) }

  before do
    switch_to_host(organization.host)
    login_as user, scope: :user
    visit decidim_admin_templates.proposal_answer_templates_path
  end

  describe "listing templates" do
    let!(:template) { create(:template, :proposal_answer, organization:) }

    before do
      visit decidim_admin_templates.proposal_answer_templates_path
    end

    it "shows a table with the templates info" do
      within ".proposal_answer-templates" do
        expect(page).to have_i18n_content(template.name)
        expect(page).to have_i18n_content("Global (available everywhere)")
      end
    end

    context "when a template is scoped to an invalid resource" do
      let!(:template) { create(:template, :proposal_answer, organization:, templatable: create(:dummy_resource)) }

      it "shows a table info about the invalid resource" do
        within ".proposal_answer-templates" do
          expect(page).to have_i18n_content(template.name)
          expect(page).to have_i18n_content("(missing resource)")
        end
      end
    end
  end

  describe "creating a proposal_answer_template" do
    let(:participatory_process) { create(:participatory_process, title: { en: "A participatory process" }, organization:) }
    let!(:proposals_component) { create(:component, manifest_name: :proposals, name: { en: "A component" }, participatory_space: participatory_process) }

    before do
      within ".layout-content" do
        click_link("New")
      end
    end

    shared_examples "creates a new template with scopes" do |scope_name|
      it "creates a new template" do
        within ".new_proposal_answer_template" do
          fill_in_i18n(
            :proposal_answer_template_name,
            "#proposal_answer_template-name-tabs",
            en: "My template",
            es: "Mi plantilla",
            ca: "La meva plantilla"
          )
          fill_in_i18n_editor(
            :proposal_answer_template_description,
            "#proposal_answer_template-description-tabs",
            en: "Description",
            es: "Descripción",
            ca: "Descripció"
          )

          choose "Not answered"
          select scope_name, from: :proposal_answer_template_scope_for_availability

          page.find("*[type=submit]").click
        end

        expect(page).to have_admin_callout("successfully")
        expect(page).to have_current_path decidim_admin_templates.proposal_answer_templates_path
        within ".proposal_answer-templates" do
          expect(page).to have_i18n_content(scope_name)
          expect(page).to have_content("My template")
        end
      end
    end

    it_behaves_like "creates a new template with scopes", "Global (available everywhere)"
    it_behaves_like "creates a new template with scopes", "Participatory process: A participatory process > A component"
  end

  describe "updating a template" do
    let!(:template) { create(:template, :proposal_answer, organization:) }
    let(:participatory_process) { create(:participatory_process, title: { en: "A participatory process" }, organization:) }
    let!(:proposals_component) { create(:component, manifest_name: :proposals, name: { en: "A component" }, participatory_space: participatory_process) }

    before do
      visit decidim_admin_templates.proposal_answer_templates_path
      click_link translated(template.name)
    end

    shared_examples "updates a template with scopes" do |scope_name|
      it "updates a template" do
        fill_in_i18n(
          :proposal_answer_template_name,
          "#proposal_answer_template-name-tabs",
          en: "My new name",
          es: "Mi nuevo nombre",
          ca: "El meu nou nom"
        )

        select scope_name, from: :proposal_answer_template_scope_for_availability

        within ".edit_proposal_answer_template" do
          page.find("*[type=submit]").click
        end

        expect(page).to have_admin_callout("successfully")
        expect(page).to have_current_path decidim_admin_templates.proposal_answer_templates_path
        within ".proposal_answer-templates" do
          expect(page).to have_i18n_content(scope_name)
          expect(page).to have_content("My new name")
        end
      end
    end

    it_behaves_like "updates a template with scopes", "Global (available everywhere)"
    it_behaves_like "updates a template with scopes", "Participatory process: A participatory process > A component"
  end

  describe "updating a template with invalid values" do
    let!(:template) { create(:template, :proposal_answer, organization:) }

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
    let!(:template) { create(:template, :proposal_answer, organization:) }

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
    let!(:template) { create(:template, :proposal_answer, organization:) }

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

  describe "using a proposal_answer_template" do
    let(:participatory_process) { create(:participatory_process, title: { en: "A participatory process" }, organization:) }
    let!(:component) { create(:component, manifest_name: :proposals, name: { en: "A component" }, participatory_space: participatory_process) }

    let(:description) { "Some meaningful answer" }
    let(:values) do
      { internal_state: "rejected" }
    end
    let!(:template) { create(:template, :proposal_answer, description: { en: description }, field_values: values, organization:, templatable: component) }
    let!(:proposal) { create(:proposal, component:) }

    before do
      visit Decidim::EngineRouter.admin_proxy(component).root_path
      find("a", class: "action-icon--show-proposal").click
    end

    it "uses the template" do
      within ".edit_proposal_answer" do
        select template.name["en"], from: :proposal_answer_template_chooser
        expect(page).to have_content(description)
        click_button "Answer"
      end

      expect(page).to have_admin_callout("Proposal successfully answered")

      within find("tr", text: proposal.title["en"]) do
        expect(page).to have_content("Rejected")
      end
    end
  end
end
