# frozen_string_literal: true

require "spec_helper"

describe "Admin filters proposals", type: :system do
  include_context "when admin manages proposals"
  include_context "with filterable context"

  STATES = Decidim::Proposals::Proposal::POSSIBLE_STATES.map(&:to_sym)

  let(:model_name) { Decidim::Proposals::Proposal.model_name }
  let(:resource_controller) { Decidim::Proposals::Admin::ProposalsController }

  def create_proposal_with_trait(trait)
    create(:proposal, trait, component:, skip_injection: true)
  end

  def proposal_with_state(state)
    Decidim::Proposals::Proposal.where(component:).find_by(state:)
  end

  def proposal_without_state(state)
    Decidim::Proposals::Proposal.where(component:).where.not(state:).sample
  end

  context "when filtering by state" do
    let!(:proposals) do
      STATES.map { |state| create_proposal_with_trait(state) }
    end

    before { visit_component_admin }

    STATES.without(:not_answered).each do |state|
      i18n_state = I18n.t(state, scope: "decidim.admin.filters.proposals.state_eq.values")

      context "filtering proposals by state: #{i18n_state}" do
        it_behaves_like "a filtered collection", options: "State", filter: i18n_state do
          let(:in_filter) { translated(proposal_with_state(state).title) }
          let(:not_in_filter) { translated(proposal_without_state(state).title) }
        end
      end
    end

    it_behaves_like "a filtered collection", options: "State", filter: "Not answered" do
      let(:in_filter) { translated(proposal_with_state(nil).title) }
      let(:not_in_filter) { translated(proposal_without_state(nil).title) }
    end
  end

  context "when filtering by type" do
    let!(:emendation) { create(:proposal, component:, skip_injection: true) }
    let(:emendation_title) { translated(emendation.title) }
    let!(:amendable) { create(:proposal, component:, skip_injection: true) }
    let(:amendable_title) { translated(amendable.title) }
    let!(:amendment) { create(:amendment, amendable:, emendation:) }

    before { visit_component_admin }

    it_behaves_like "a filtered collection", options: "Type", filter: "Proposals" do
      let(:in_filter) { amendable_title }
      let(:not_in_filter) { emendation_title }
    end

    it_behaves_like "a filtered collection", options: "Type", filter: "Amendments" do
      let(:in_filter) { emendation_title }
      let(:not_in_filter) { amendable_title }
    end
  end

  context "when filtering by scope" do
    let!(:scope1) { create(:scope, organization:, name: { "en" => "Scope1" }) }
    let!(:scope2) { create(:scope, organization:, name: { "en" => "Scope2" }) }
    let!(:proposal_with_scope1) { create(:proposal, component:, skip_injection: true, scope: scope1) }
    let(:proposal_with_scope1_title) { translated(proposal_with_scope1.title) }
    let!(:proposal_with_scope2) { create(:proposal, component:, skip_injection: true, scope: scope2) }
    let(:proposal_with_scope2_title) { translated(proposal_with_scope2.title) }

    before { visit_component_admin }

    it_behaves_like "a filtered collection", options: "Scope", filter: "Scope1" do
      let(:in_filter) { proposal_with_scope1_title }
      let(:not_in_filter) { proposal_with_scope2_title }
    end

    it_behaves_like "a filtered collection", options: "Scope", filter: "Scope2" do
      let(:in_filter) { proposal_with_scope2_title }
      let(:not_in_filter) { proposal_with_scope1_title }
    end
  end

  context "when searching by ID or title" do
    let!(:proposal1) { create(:proposal, component:, skip_injection: true) }
    let!(:proposal2) { create(:proposal, component:, skip_injection: true) }
    let!(:proposal1_title) { translated(proposal1.title) }
    let!(:proposal2_title) { translated(proposal2.title) }

    before { visit_component_admin }

    it "can be searched by ID" do
      search_by_text(proposal1.id)

      expect(page).to have_content(proposal1_title)
    end

    it "can be searched by title" do
      search_by_text(proposal2_title)

      expect(page).to have_content(proposal2_title)
    end
  end

  it_behaves_like "paginating a collection" do
    let!(:collection) { create_list(:proposal, 50, component:, skip_injection: true) }
  end
end
