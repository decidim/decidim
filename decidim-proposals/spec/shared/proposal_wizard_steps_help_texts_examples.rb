# frozen_string_literal: true

shared_examples "manage proposal wizard steps help texts" do
  before do
    current_feature.update_attributes!(
      step_settings: {
        current_feature.participatory_space.active_step.id => {
          creation_enabled: true
        }
      }
    )
  end
  let!(:proposal) { create(:proposal, feature: current_feature) }
  let!(:proposal_similar) { create(:proposal, feature: current_feature, title: "This proposal is to ensure a similar exists") }
  let!(:proposal_draft) { create(:proposal, :draft, feature: current_feature, title: "This proposal has a similar") }

  it "customize the help text for step 1 of the proposal wizard" do
    visit edit_feature_path(current_feature)

    fill_in_i18n_editor(
      :feature_settings_proposal_wizard_step_1_help_text,
      "#global-settings-proposal_wizard_step_1_help_text-tabs",
      en: "This is the first step of the Proposal creation wizard.",
      es: "Este es el primer paso del asistente de creación de propuestas.",
      ca: "Aquest és el primer pas de l'assistent de creació de la proposta."
    )

    click_button "Update"

    visit new_proposal_path(current_feature)
    within ".proposal_wizard_help_text" do
      expect(page).to have_content("This is the first step of the Proposal creation wizard.")
    end
  end

  it "customize the help text for step 2 of the proposal wizard" do
    visit edit_feature_path(current_feature)

    fill_in_i18n_editor(
      :feature_settings_proposal_wizard_step_2_help_text,
      "#global-settings-proposal_wizard_step_2_help_text-tabs",
      en: "This is the second step of the Proposal creation wizard.",
      es: "Este es el segundo paso del asistente de creación de propuestas.",
      ca: "Aquest és el segon pas de l'assistent de creació de la proposta."
    )

    click_button "Update"

    visit compare_proposal_path(current_feature, proposal_draft)
    within ".proposal_wizard_help_text" do
      expect(page).to have_content("This is the second step of the Proposal creation wizard.")
    end
  end

  it "customize the help text for step 3 of the proposal wizard" do
    visit edit_feature_path(current_feature)

    fill_in_i18n_editor(
      :feature_settings_proposal_wizard_step_3_help_text,
      "#global-settings-proposal_wizard_step_3_help_text-tabs",
      en: "This is the third step of the Proposal creation wizard.",
      es: "Este es el tercer paso del asistente de creación de propuestas.",
      ca: "Aquest és el tercer pas de l'assistent de creació de la proposta."
    )

    click_button "Update"

    visit preview_proposal_path(current_feature, proposal_draft)
    within ".proposal_wizard_help_text" do
      expect(page).to have_content("This is the third step of the Proposal creation wizard.")
    end
  end

  private

  def new_proposal_path(current_feature)
    Decidim::EngineRouter.main_proxy(current_feature).new_proposal_path(current_feature.id)
  end

  def compare_proposal_path(_current_feature, proposal)
    Decidim::EngineRouter.main_proxy(feature).compare_proposal_path(proposal)
    # Decidim::ResourceLocatorPresenter.new(proposal).path + "/compare"
  end

  def preview_proposal_path(current_feature, proposal)
    Decidim::EngineRouter.main_proxy(current_feature).preview_proposal_path(proposal)
  end
end
