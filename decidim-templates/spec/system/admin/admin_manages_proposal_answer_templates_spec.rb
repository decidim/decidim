# frozen_string_literal: true

require "spec_helper"

describe "Admin manages proposal answer templates" do
  let(:description) { "A component" }
  let(:field_values) { { proposal_state_id: } }
  let(:token) { "rejected" }
  let!(:organization) { create(:organization) }
  let!(:user) { create(:user, :admin, :confirmed, organization:) }
  let(:participatory_space) { create(:participatory_process, title: { en: "A participatory process" }, organization:) }
  let!(:templatable) { create(:proposal_component, name: { en: description }, participatory_space:) }
  let(:proposal_state_id) { Decidim::Proposals::ProposalState.find_by(component: templatable, token:).id }
  let!(:template) { create(:template, target: :proposal_answer, organization:, templatable:, field_values:) }

  before do
    switch_to_host(organization.host)
    login_as user, scope: :user
    visit decidim_admin_templates.proposal_answer_templates_path
  end

  describe "listing templates" do
    before do
      visit decidim_admin_templates.proposal_answer_templates_path
    end

    context "when a template is scoped to an invalid resource" do
      it "shows a table info about the invalid resource" do
        within ".table-list" do
          expect(page).to have_i18n_content(template.name)
          expect(page).to have_i18n_content("A component")
        end
      end
    end
  end

  describe "creating a proposal_answer_template" do
    before do
      within ".layout-content" do
        click_link("New")
      end
    end

    it "creates a new template" do
      within ".new_proposal_answer_template" do
        select "Participatory process: A participatory process > A component", from: :proposal_answer_template_component_constraint
      end

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

        choose "Accepted"

        page.find("*[type=submit]").click
      end

      expect(page).to have_admin_callout("successfully")
      expect(page).to have_current_path decidim_admin_templates.proposal_answer_templates_path
      within ".table-list" do
        expect(page).to have_i18n_content("Participatory process: A participatory process > A component")
        expect(page).to have_content("My template")
      end
    end
  end

  describe "updating a template" do
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
      expect(page).to have_current_path decidim_admin_templates.proposal_answer_templates_path
      within ".table-list" do
        expect(page).to have_i18n_content("Participatory process: A participatory process > A component")
        expect(page).to have_content("My new name")
      end
    end
  end

  describe "updating a template with invalid values" do
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
    let(:description) { "Some meaningful answer" }

    let!(:template) { create(:template, target: :proposal_answer, description: { en: description }, organization:, templatable:, field_values:) }

    let!(:proposal) { create(:proposal, component: templatable) }

    before do
      visit Decidim::EngineRouter.admin_proxy(templatable).root_path
      find("a", class: "action-icon--show-proposal").click
    end

    it "uses the template" do
      expect(proposal.reload.customized_proposal_internal_state).to eq("not_answered")
      within ".edit_proposal_answer" do
        select template.name["en"], from: :proposal_answer_template_chooser
        expect(page).to have_content(description)
        click_button "Answer"
      end

      expect(page).to have_admin_callout("Proposal successfully answered")

      within find("tr", text: proposal.title["en"]) do
        expect(page).to have_content("Rejected")
      end
      expect(proposal.reload.customized_proposal_internal_state).to eq("rejected")
    end

    context "when there are no templates" do
      before do
        template.destroy!
        visit Decidim::EngineRouter.admin_proxy(templatable).root_path
        find("a", class: "action-icon--show-proposal").click
      end

      it "hides the template selector in the proposal answer page" do
        expect(page).not_to have_select(:proposal_answer_template_chooser)
      end
    end

    context "when displaying current component and organization templates" do
      let!(:other_component) { create(:proposal_component, name: { en: "Another component" }, participatory_space:) }
      let!(:other_component_template) { create(:template, target: :proposal_answer, description: { en: "Foo bar" }, field_values:, organization:, templatable: other_component) }

      before do
        visit Decidim::EngineRouter.admin_proxy(templatable).root_path
        find("a", class: "action-icon--show-proposal").click
      end

      it "displays the global template in dropdown" do
        expect(page).to have_select(:proposal_answer_template_chooser, with_options: [translated(template.name)])
      end

      it "hides templates scoped for other components" do
        expect(proposal.reload.customized_proposal_internal_state).to eq("not_answered")
        expect(page).not_to have_select(:proposal_answer_template_chooser, with_options: [translated(other_component_template.name)])
      end
    end

    context "when the template uses interpolations" do
      let(:template_settings) { { target: :proposal_answer, organization:, templatable:, field_values: } }
      let!(:template) { create(:template, description: { "en" => template_desc }, **template_settings) }

      context "with the organization variable" do
        let(:template_desc) { "Some meaningful answer with the %{organization}" }

        it "changes it with the organization name" do
          within ".edit_proposal_answer" do
            select template.name["en"], from: :proposal_answer_template_chooser
            expect(page).to have_content("Some meaningful answer with the #{organization.name}")
          end
        end
      end

      context "with the admin variable" do
        let(:template_desc) { "Some meaningful answer with the %{admin}" }

        it "changes it with the admin's user name" do
          within ".edit_proposal_answer" do
            select template.name["en"], from: :proposal_answer_template_chooser
            expect(page).to have_content("Some meaningful answer with the #{user.name}")
          end
        end
      end

      context "with the user variable" do
        let(:template_desc) { "Some meaningful answer with the %{name}" }

        it "changes it with the author's user name" do
          within ".edit_proposal_answer" do
            select template.name["en"], from: :proposal_answer_template_chooser
            expect(page).to have_content("Some meaningful answer with the #{proposal.creator_author.name}")
          end
        end
      end
    end
  end
end
