# frozen_string_literal: true

shared_examples "bulk update answer proposals" do
  let!(:state) { Decidim::Proposals::ProposalState.first }
  let!(:proposal) { create(:proposal, cost: nil, component: current_component) }
  let!(:emendation) { create(:proposal, component: current_component) }
  let!(:amendment) { create(:amendment, amendable: proposal, emendation:) }
  let!(:template) { create(:template, target: :proposal_answer, templatable: current_component, description:, field_values:) }
  let(:field_values) do
    { "proposal_state_id" => state.id }
  end
  let(:description) do
    { en: "Hi %{name}, this proposal will be implemented in %{organization}. Signed: %{admin}" }
  end

  before do
    visit current_path
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
    end

    expect(page).to have_content("4 proposals will be answered using the template")
    expect(page).to have_content("Proposals with IDs [#{emendation.id}] could not be answered due errors applying the template")
    expect(proposal.reload.proposal_state).to eq(state)
    expect(proposal.answer["en"]).to include("Hi #{proposal.creator_author.name}, this proposal will be implemented in #{organization.name["en"]}. Signed: #{user.name}")
    reportables.each do |reportable|
      expect(reportable.reload.proposal_state).to eq(state)
      expect(reportable.answer["en"]).to include("Hi #{reportable.creator_author.name}, this proposal will be implemented in #{organization.name["en"]}. Signed: #{user.name}")
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
      current_component.update!(
        step_settings: {
          current_component.participatory_space.active_step.id => {
            answers_with_costs: true
          }
        }
      )
    end

    it "does not apply the template" do
      expect(proposal.proposal_state).to be_nil
      click_on "Apply answer template"
      expect(page).to have_css("#template_template_id", count: 1)
      select translated(template.name), from: :template_template_id
      perform_enqueued_jobs do
        click_on "Update"
      end

      expect(page).to have_no_content("proposals will be answered using the template")
      expect(page).to have_content("could not be answered due errors applying the template")
      expect(proposal.reload.proposal_state).to be_nil
      reportables.each do |reportable|
        expect(reportable.reload.proposal_state).to be_nil
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
