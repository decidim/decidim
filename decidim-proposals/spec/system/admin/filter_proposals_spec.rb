# frozen_string_literal: true

require "spec_helper"

describe "Admin filters proposals" do
  include_context "when admin manages proposals"
  include_context "with filterable context"

  STATES = { evaluating: 10, accepted: 20, rejected: -10 }.keys

  let(:model_name) { Decidim::Proposals::Proposal.model_name }
  let(:resource_controller) { Decidim::Proposals::Admin::ProposalsController }

  def create_proposal_with_trait(trait)
    create(:proposal, trait, component:)
  end

  def proposal_with_state(token)
    proposal_state = Decidim::Proposals::ProposalState.where(component:, token:).first
    Decidim::Proposals::Proposal.where(component:).find_by(proposal_state:)
  end

  def proposal_without_state(token)
    proposal_state = Decidim::Proposals::ProposalState.where(component:, token:).first
    Decidim::Proposals::Proposal.where(component:).where.not(proposal_state:).sample
  end

  context "when filtering by answered" do
    let!(:answered_proposal) { create(:proposal, :with_answer, component:) }
    let!(:unanswered_proposal) { create(:proposal, component:) }

    before { visit_component_admin }

    context "when filtering proposals by Answered" do
      it_behaves_like "a filtered collection", options: "Answered", filter: "Answered" do
        let(:in_filter) { translated(answered_proposal.title) }
        let(:not_in_filter) { translated(unanswered_proposal.title) }
      end
    end

    context "when filtering proposals by Not answered" do
      it_behaves_like "a filtered collection", options: "Answered", filter: "Not answered" do
        let(:in_filter) { translated(unanswered_proposal.title) }
        let(:not_in_filter) { translated(answered_proposal.title) }
      end
    end
  end

  context "when filtering by state" do
    let!(:proposals) do
      STATES.map { |state| create_proposal_with_trait(state) }
    end

    let!(:withdrawn_proposal) { create_proposal_with_trait(:withdrawn) }

    before { visit_component_admin }

    STATES.each do |state|
      i18n_state = I18n.t(state, scope: "decidim.admin.filters.proposals.state_eq.values")

      context "when filtering proposals by state: #{i18n_state}" do
        it_behaves_like "a filtered collection", options: "State", filter: i18n_state do
          let(:in_filter) { translated(proposal_with_state(state).title) }
          let(:not_in_filter) { translated(proposal_without_state(state).title) }
        end
      end
    end

    context "when filtering proposals by state: Withdrawn" do
      it_behaves_like "a filtered collection", options: "State", filter: "Withdrawn" do
        let(:in_filter) { translated(withdrawn_proposal.title) }
        let(:not_in_filter) { translated(proposals.sample.title) }
      end
    end
  end

  context "when filtering by type" do
    let!(:emendation) { create(:proposal, component:) }
    let(:emendation_title) { translated(emendation.title) }
    let!(:amendable) { create(:proposal, component:) }
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
    let!(:proposal_with_scope1) { create(:proposal, component:, scope: scope1) }
    let(:proposal_with_scope1_title) { translated(proposal_with_scope1.title) }
    let!(:proposal_with_scope2) { create(:proposal, component:, scope: scope2) }
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
    let!(:proposal1) { create(:proposal, component:) }
    let!(:proposal2) { create(:proposal, component:) }
    let!(:proposal1_title) { ActionView::Base.full_sanitizer.sanitize(translated(proposal1.title)) }
    let!(:proposal2_title) { ActionView::Base.full_sanitizer.sanitize(translated(proposal2.title)) }

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
    let!(:collection) { create_list(:proposal, 50, component:) }
  end
end
