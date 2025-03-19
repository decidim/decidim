# frozen_string_literal: true

require "spec_helper"

describe "Evaluator uses proposal answer templates" do
  let(:field_values) { { proposal_state_id: } }
  let(:token) { "rejected" }
  let!(:organization) { create(:organization) }
  let(:user) { create(:user, :confirmed, :admin_terms_accepted, organization:) }
  let!(:evaluator_role) { create(:participatory_process_user_role, role: :evaluator, user:, participatory_process: participatory_space) }
  let!(:evaluation_assignment) { create(:evaluation_assignment, proposal:, evaluator_role:) }
  let(:participatory_space) { create(:participatory_process, title: { en: "A participatory process" }, organization:) }
  let!(:templatable) { create(:proposal_component, name: { en: "A component" }, participatory_space:) }
  let(:proposal_state_id) { Decidim::Proposals::ProposalState.find_by(component: templatable, token:).id }
  let(:description) { "Some meaningful answer" }
  let!(:template) { create(:template, target: :proposal_answer, description: { en: description }, organization:, templatable:, field_values:) }
  let!(:proposal) { create(:proposal, component: templatable) }
  let!(:other_component) { create(:proposal_component, name: { en: "Another component" }, participatory_space:) }
  let!(:other_component_template) { create(:template, target: :proposal_answer, description: { en: "Foo bar" }, field_values:, organization:, templatable: other_component) }

  before do
    switch_to_host(organization.host)
    login_as user, scope: :user
    visit Decidim::EngineRouter.admin_proxy(templatable).root_path
    find("a", class: "action-icon--show-proposal").click
  end

  it "uses the template" do
    expect(proposal.reload.internal_state).to eq("not_answered")
    within ".edit_proposal_answer" do
      expect(page).to have_select(:proposal_answer_template_chooser, with_options: [translated(template.name)])
      expect(page).to have_no_select(:proposal_answer_template_chooser, with_options: [translated(other_component_template.name)])
      select template.name["en"], from: :proposal_answer_template_chooser
      expect(page).to have_content(description)
      click_on "Answer"
    end

    expect(page).to have_admin_callout("Proposal successfully answered")

    within "tr", text: proposal.title["en"] do
      expect(page).to have_content("Rejected")
    end
    expect(proposal.reload.internal_state).to eq("rejected")
  end

  context "when there are no templates" do
    before do
      template.destroy!
      visit Decidim::EngineRouter.admin_proxy(templatable).root_path
      find("a", class: "action-icon--show-proposal").click
    end

    it "hides the template selector in the proposal answer page" do
      expect(page).to have_no_select(:proposal_answer_template_chooser)
    end
  end

  context "when the template is destroyed while in the page" do
    it "shows an error message if the template is removed" do
      within ".edit_proposal_answer" do
        template.destroy!
        select template.name["en"], from: :proposal_answer_template_chooser
        expect(page).to have_no_content(description)
        expect(page).to have_content("Could not find this template")
      end
    end
  end
end
