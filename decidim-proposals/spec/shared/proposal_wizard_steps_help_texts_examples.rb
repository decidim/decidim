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
  let!(:proposal) { create(:proposal, feature: feature) }

  it "customize the help text for each proposal wizard step" do
    visit edit_feature_path(current_feature)

    fill_in_i18n_editor(
      :feature_settings_proposal_wizard_step_1_help_text,
      "#global-settings-proposal_wizard_step_1_help_text-tabs",
      en: "This is the first step of the Proposal creation wizard.",
      es: "Este es el primer paso del asistente de creación de propuestas.",
      ca: "Aquest és el primer pas de l'assistent de creació de la proposta."
    )

    fill_in_i18n_editor(
      :feature_settings_proposal_wizard_step_2_help_text,
      "#global-settings-proposal_wizard_step_2_help_text-tabs",
      en: "This is the second step of the Proposal creation wizard.",
      es: "Este es el segundo paso del asistente de creación de propuestas.",
      ca: "Aquest és el segon pas de l'assistent de creació de la proposta."
    )

    fill_in_i18n_editor(
      :feature_settings_proposal_wizard_step_3_help_text,
      "#global-settings-proposal_wizard_step_3_help_text-tabs",
      en: "This is the third step of the Proposal creation wizard.",
      es: "Este es el tercer paso del asistente de creación de propuestas.",
      ca: "Aquest és el tercer pas de l'assistent de creació de la proposta."
    )

    click_button "Update"
  end

  context "in the first step" do
    before do
      visit new_proposal_path(current_feature)
    end

    it "Shows the first step help text" do
      within ".proposal_wizard_help_text" do
        expect(page).to have_content("This is the first step of the Proposal creation wizard.")
      end
    end
  end

  context "in the second step" do
    before do
      visit compare_proposal_path(current_feature, proposal)
    end

    it "Shows the second step help text" do
      within ".proposal_wizard_help_text" do
        expect(page).to have_content("This is the second step of the Proposal creation wizard.")
      end
    end
  end

  context "in the third step" do
    before do
      visit preview_proposal_path(current_feature, proposal)
    end

    it "Shows the second step help text" do
      within ".proposal_wizard_help_text" do
        expect(page).to have_content("This is the third step of the Proposal creation wizard.")
      end
    end
  end

  private

  def new_proposal_path(feature)
    Decidim::EngineRouter.main_proxy(feature).new_proposal_path(current_feature.id)
  end

  def compare_proposal_path(feature, proposal)
    Decidim::EngineRouter.main_proxy(feature).compare_proposal_path(proposal)
  end

  def preview_proposal_path(feature, proposal)
    Decidim::EngineRouter.main_proxy(feature).preview_proposal_path(proposal)
  end
end
