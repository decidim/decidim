# frozen_string_literal: true

shared_examples "manage proposals help texts" do
  before do
    current_feature.update_attributes(
      step_settings: {
        current_feature.participatory_process.active_step.id => {
          creation_enabled: true
        }
      }
    )
  end

  it "customize a help text for the new proposal page" do
    visit edit_feature_path(current_feature)

    fill_in_i18n_editor(
      :feature_settings_new_proposal_help_text,
      "#global-settings-new_proposal_help_text-tabs",
      en: "Create a proposal following our guidelines.",
      es: "Crea una propuesta siguiendo nuestra guía de estilo.",
      ca: "Crea una proposta seguint la nostra guia d'estil."
    )

    click_button "Update"

    visit decidim_proposals.new_proposal_path(feature_id: current_feature.id, participatory_process_id: current_feature.participatory_process.id)

    within ".callout.secondary" do
      expect(page).to have_content("Create a proposal following our guidelines.")
    end
  end
end
