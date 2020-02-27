# frozen_string_literal: true

shared_examples "filter proposals" do
  STATES = Decidim::Proposals::Proposal::POSSIBLE_STATES.map(&:to_sym)

  def create_proposal_with_trait(trait)
    create(:proposal, trait, component: component)
  end

  def proposal_with_state(state)
    Decidim::Proposals::Proposal.where(component: component).find_by(state: state)
  end

  def proposal_without_state(state)
    Decidim::Proposals::Proposal.where(component: component).where.not(state: state).sample
  end

  include_context "with filterable context"

  let(:model_name) { Decidim::Proposals::Proposal.model_name }

  context "when filtering by state" do
    let!(:proposals) do
      STATES.map { |state| create_proposal_with_trait(state) }
    end

    before { visit_component_admin }

    STATES.without(:not_answered).each do |state|
      i18n_state = I18n.t(state, scope: "decidim.admin.filters.state_eq.values")

      context "filtering proposals by state: #{i18n_state}" do
        it_behaves_like "a filtered collection", options: "State", filter: i18n_state do
          let(:in_filter) { proposal_with_state(state).title }
          let(:not_in_filter) { proposal_without_state(state).title }
        end
      end
    end

    it_behaves_like "a filtered collection", options: "State", filter: "Not answered" do
      let(:in_filter) { proposal_with_state(nil).title }
      let(:not_in_filter) { proposal_without_state(nil).title }
    end
  end

  context "when filtering by type" do
    let!(:emendation) { create(:proposal, component: component) }
    let!(:amendable) { create(:proposal, component: component) }
    let!(:amendment) { create(:amendment, amendable: amendable, emendation: emendation) }

    before { visit_component_admin }

    it_behaves_like "a filtered collection", options: "Type", filter: "Proposals" do
      let(:in_filter) { amendable.title }
      let(:not_in_filter) { emendation.title }
    end

    it_behaves_like "a filtered collection", options: "Type", filter: "Amendments" do
      let(:in_filter) { emendation.title }
      let(:not_in_filter) { amendable.title }
    end
  end

  context "when filtering by scope" do
    let!(:scope1) { create(:scope, organization: organization, name: { "en" => "Scope1" }) }
    let!(:scope2) { create(:scope, organization: organization, name: { "en" => "Scope2" }) }
    let!(:proposal_with_scope1) { create(:proposal, component: component, scope: scope1) }
    let!(:proposal_with_scope2) { create(:proposal, component: component, scope: scope2) }

    before { visit_component_admin }

    it_behaves_like "a filtered collection", options: "Scope", filter: "Scope1" do
      let(:in_filter) { proposal_with_scope1.title }
      let(:not_in_filter) { proposal_with_scope2.title }
    end

    it_behaves_like "a filtered collection", options: "Scope", filter: "Scope2" do
      let(:in_filter) { proposal_with_scope2.title }
      let(:not_in_filter) { proposal_with_scope1.title }
    end
  end

  context "when searching by ID or title" do
    let!(:proposal1) { create(:proposal, component: component) }
    let!(:proposal2) { create(:proposal, component: component) }

    before { visit_component_admin }

    it "can be searched by ID" do
      search_by_text(proposal1.id)

      expect(page).to have_content(proposal1.title)
    end

    it "can be searched by title" do
      search_by_text(proposal2.title)

      expect(page).to have_content(proposal2.title)
    end
  end

  it_behaves_like "paginating a collection" do
    let!(:collection) { create_list(:proposal, 50, component: component) }
  end
end
