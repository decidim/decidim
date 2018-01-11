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

  it "customize the help text for step 1 of the proposal wizard" do
    visit edit_feature_path(current_feature)

    fill_in_i18n_editor(
      :feature_settings_proposal_wizard_step_1_help_text,
      "#global-settings-proposal_wizard_step_1_help_text-tabs",
      en: "This is the first step of the Proposal creation wizard!!",
      es: "Este es el primer paso del asistente de creación de propuestas.",
      ca: "Aquest és el primer pas de l'assistent de creació de la proposta."
    )

    click_button "Update"

    visit proposal_wizard_path(current_feature, :step_1)

    within ".callout.secondary" do
      expect(page).to have_content("This is the first step of the Proposal creation wizard!!")
    end
  end

  private

  def proposal_wizard_path(current_feature, step)
    Decidim::EngineRouter.main_proxy(current_feature).proposal_wizard_path(step)
  end
end
