# frozen_string_literal: true

shared_examples "manage proposal wizard steps help texts" do
  before do
    current_component.update!(
      step_settings: {
        current_component.participatory_space.active_step.id => {
          creation_enabled: true
        }
      }
    )
  end

  let!(:proposal) { create(:proposal, component: current_component) }
  let!(:proposal_similar) { create(:proposal, component: current_component, title: "This proposal is to ensure a similar exists") }
  let!(:proposal_draft) { create(:proposal, :draft, component: current_component, title: "This proposal has a similar") }

  it "customize the help text for step 1 of the proposal wizard" do
    visit edit_component_path(current_component)

    fill_in_i18n_editor(
      :component_settings_proposal_wizard_step_1_help_text,
      "#global-settings-proposal_wizard_step_1_help_text-tabs",
      en: "This is the first step of the Proposal creation wizard.",
      es: "Este es el primer paso del asistente de creación de propuestas.",
      ca: "Aquest és el primer pas de l'assistent de creació de la proposta."
    )

    click_button "Update"

    visit new_proposal_path(current_component)
    within ".proposal_wizard_help_text" do
      expect(page).to have_content("This is the first step of the Proposal creation wizard.")
    end
  end

  it "customize the help text for step 2 of the proposal wizard" do
    visit edit_component_path(current_component)

    fill_in_i18n_editor(
      :component_settings_proposal_wizard_step_2_help_text,
      "#global-settings-proposal_wizard_step_2_help_text-tabs",
      en: "This is the second step of the Proposal creation wizard.",
      es: "Este es el segundo paso del asistente de creación de propuestas.",
      ca: "Aquest és el segon pas de l'assistent de creació de la proposta."
    )

    click_button "Update"

    create(:proposal, title: "Agusti for president", body: "He will solve everything", component: component)
    create(:proposal, title: "Homer for president", body: "He will not solve everything", component: component)
    visit_component
    click_link "New proposal"
    within ".new_proposal" do
      fill_in :proposal_title, with: "Jordi for president"
      fill_in :proposal_body, with: "He will solve everything"

      find("*[type=submit]").click
    end

    within ".proposal_wizard_help_text" do
      expect(page).to have_content("This is the second step of the Proposal creation wizard.")
    end
  end

  it "customize the help text for step 3 of the proposal wizard" do
    visit edit_component_path(current_component)

    fill_in_i18n_editor(
      :component_settings_proposal_wizard_step_3_help_text,
      "#global-settings-proposal_wizard_step_3_help_text-tabs",
      en: "This is the third step of the Proposal creation wizard.",
      es: "Este es el tercer paso del asistente de creación de propuestas.",
      ca: "Aquest és el tercer pas de l'assistent de creació de la proposta."
    )

    click_button "Update"

    visit_component
    click_link "New proposal"
    within ".new_proposal" do
      fill_in :proposal_title, with: "Agusti for president"
      fill_in :proposal_body, with: "He will solve everything"

      find("*[type=submit]").click
    end

    within ".proposal_wizard_help_text" do
      expect(page).to have_content("This is the third step of the Proposal creation wizard.")
    end
  end

  it "customize the help text for step 4 of the proposal wizard" do
    visit edit_component_path(current_component)

    fill_in_i18n_editor(
      :component_settings_proposal_wizard_step_4_help_text,
      "#global-settings-proposal_wizard_step_4_help_text-tabs",
      en: "This is the fourth step of the Proposal creation wizard.",
      es: "Este es el cuarto paso del asistente de creación de propuestas.",
      ca: "Aquest és el quart pas de l'assistent de creació de la proposta."
    )

    click_button "Update"

    visit preview_proposal_path(current_component, proposal_draft)
    within ".proposal_wizard_help_text" do
      expect(page).to have_content("This is the fourth step of the Proposal creation wizard.")
    end
  end

  private

  def new_proposal_path(current_component)
    Decidim::EngineRouter.main_proxy(current_component).new_proposal_path(current_component.id)
  end

  def complete_proposal_path(current_component, proposal)
    Decidim::EngineRouter.main_proxy(current_component).complete_proposal_path(proposal)
  end

  def preview_proposal_path(current_component, proposal)
    Decidim::EngineRouter.main_proxy(current_component).proposal_path(proposal) + "/preview"
  end
end
