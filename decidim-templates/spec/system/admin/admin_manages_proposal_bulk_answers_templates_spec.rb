# frozen_string_literal: true

require "spec_helper"

describe "Admin manages bulk proposal answer templates" do
  let(:organization) { create(:organization) }
  let(:participatory_process) { create(:participatory_process, :with_steps, organization:) }
  let(:participatory_space) { participatory_process }
  let!(:component) { create(:proposal_component, participatory_space:) }
  let(:user) { create(:user, :admin, :confirmed, organization:) }
  let!(:state) { Decidim::Proposals::ProposalState.first }
  let!(:proposal) { create(:proposal, cost: nil, component:) }
  let!(:other_proposals) { create_list(:proposal, 3, component:) }
  let!(:emendation) { create(:proposal, component:) }
  let!(:amendment) { create(:amendment, amendable: proposal, emendation:) }
  let!(:template) { create(:template, target: :proposal_answer, templatable: component, description:, field_values:) }
  let(:field_values) do
    { "proposal_state_id" => state.id }
  end
  let(:description) do
    { en: "Hi %{name}, this proposal will be implemented in %{organization}. Signed: %{admin}" }
  end

  before do
    switch_to_host(organization.host)
    login_as user, scope: :user
    visit manage_component_path(component)
    # visit current_path
    page.find(".js-check-all").set(true)
    click_on "Actions"
  end

  it "applies the template" do
    expect(proposal.proposal_state).not_to eq(state)
    click_on "Apply answer template"
    expect(page).to have_css("#template_template_id", count: 1)
    select translated(template.name), from: :template_template_id
    perform_enqueued_jobs do
      click_on "Update"
      sleep(1)
    end

    expect(page).to have_content("4 proposals will be answered using the template")
    expect(page).to have_content("Proposals with IDs [#{emendation.id}] could not be answered due errors applying the template")
    expect(proposal.reload.proposal_state).to eq(state)
    expect(proposal.answer["en"]).to include("Hi #{proposal.creator_author.name}, this proposal will be implemented in #{organization.name["en"]}. Signed: #{user.name}")
    other_proposals.each do |reportable|
      expect(reportable.reload.proposal_state).to eq(state)
      expect(reportable.answer["en"]).to include("Hi #{reportable.creator_author.name}, this proposal will be implemented in #{organization.name["en"]}. Signed: #{user.name}")
    end
  end

  context "when the proposal is official" do
    let!(:proposal) { create(:proposal, :official, component:) }

    it "applies the template" do
      expect(proposal.proposal_state).not_to eq(state)
      click_on "Apply answer template"
      expect(page).to have_css("#template_template_id", count: 1)
      select translated(template.name), from: :template_template_id
      perform_enqueued_jobs do
        click_on "Update"
        sleep(1)
      end

      expect(page).to have_content("4 proposals will be answered using the template")
      expect(page).to have_content("Proposals with IDs [#{emendation.id}] could not be answered due errors applying the template")
      expect(proposal.reload.proposal_state).to eq(state)
      expect(proposal.answer["en"]).to include("Hi #{organization.name["en"]}, this proposal will be implemented in #{organization.name["en"]}. Signed: #{user.name}")
    end
  end

  context "when selected proposals are not answerable" do
    before do
      page.find(".js-check-all").set(false)
      page.find(".js-proposal-id-#{emendation.id}").set(true)
    end

    it "does not apply the template" do
      expect(page).to have_no_button("Apply answer template")
    end
  end

  context "when proposals have costs enabled" do
    let!(:state) { Decidim::Proposals::ProposalState.find_by(token: "accepted") }

    before do
      component.update!(
        step_settings: {
          component.participatory_space.active_step.id => {
            answers_with_costs: true
          }
        }
      )
    end

    it "applies the template" do
      expect(proposal.proposal_state).to be_nil
      click_on "Apply answer template"
      expect(page).to have_css("#template_template_id", count: 1)
      select translated(template.name), from: :template_template_id
      perform_enqueued_jobs do
        click_on "Update"
        sleep(1)
      end

      expect(page).to have_content("4 proposals will be answered using the template")
      expect(page).to have_content("Proposals with IDs [#{emendation.id}] could not be answered due errors applying the template")
      expect(proposal.reload.proposal_state).to eq(state)
      other_proposals.each do |reportable|
        expect(reportable.reload.proposal_state).to eq(state)
      end
    end
  end

  context "when no templates available" do
    let(:template) { nil }

    it "shows no templates message" do
      expect(page).to have_no_button("Apply answer template")
    end
  end

  context "when templates is not installed" do
    before do
      allow(Decidim).to receive(:module_installed?).and_call_original
      allow(Decidim).to receive(:module_installed?).with(:templates).and_return(false)
      visit current_path
      page.find(".js-check-all").set(true)
      click_on "Actions"
    end

    it "does not apply the template" do
      expect(page).to have_no_button("Apply answer template")
    end
  end
end
