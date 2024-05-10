# frozen_string_literal: true

require "spec_helper"

describe "Admin views admin logs" do
  let!(:organization) { create(:organization) }
  let!(:user) { create(:user, :admin, :confirmed, organization:) }
  let(:participatory_space) { create(:participatory_process, title: { en: "A participatory process" }, organization:) }

  before do
    switch_to_host(organization.host)
    login_as user, scope: :user
  end

  describe "proposal templates" do
    let!(:templatable) { create(:proposal_component, name: { en: "A component" }, participatory_space:) }
    let(:field_values) { { proposal_state_id: } }
    let(:proposal_state_id) { Decidim::Proposals::ProposalState.find_by(component: templatable, token: "rejected").id }
    let!(:template) { create(:template, target: :proposal_answer, organization:, templatable:, field_values:) }
    let(:attributes) { attributes_for(:template, target: :proposal_answer, organization:, templatable:, field_values:) }

    before do
      visit decidim_admin_templates.proposal_answer_templates_path
    end

    it "creates a new template", versioning: true do
      click_on "New template"
      within ".new_proposal_answer_template" do
        select "Participatory process: A participatory process > A component", from: :proposal_answer_template_component_constraint
        fill_in_i18n(:proposal_answer_template_name, "#proposal_answer_template-name-tabs", **attributes[:name].except("machine_translations"))
        fill_in_i18n_editor(:proposal_answer_template_description, "#proposal_answer_template-description-tabs", **attributes[:description].except("machine_translations"))

        choose "Accepted"

        page.find("*[type=submit]").click
      end

      expect(page).to have_admin_callout("successfully")
      visit decidim_admin.root_path
      expect { accept_alert }.to raise_error(Capybara::ModalNotFound)
    end

    it "updates a template", versioning: true do
      within "tr", text: translated(template.name) do
        click_on "Edit"
      end
      fill_in_i18n(:proposal_answer_template_name, "#proposal_answer_template-name-tabs", **attributes[:name].except("machine_translations"))
      fill_in_i18n_editor(:proposal_answer_template_description, "#proposal_answer_template-description-tabs", **attributes[:description].except("machine_translations"))

      within ".edit_proposal_answer_template" do
        page.find("*[type=submit]").click
      end

      expect(page).to have_admin_callout("successfully")
      visit decidim_admin.root_path
      expect { accept_alert }.to raise_error(Capybara::ModalNotFound)
    end
  end
end
