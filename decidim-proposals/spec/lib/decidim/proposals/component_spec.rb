# frozen_string_literal: true

require "spec_helper"

describe "Proposals component" do # rubocop:disable RSpec/DescribeClass
  let!(:component) { create(:proposal_component) }
  let!(:current_user) { create(:user, organization: component.participatory_space.organization) }

  describe "on destroy" do
    context "when there are no proposals for the component" do
      it "destroys the component" do
        expect do
          Decidim::Admin::DestroyComponent.call(component, current_user)
        end.to change { Decidim::Component.count }.by(-1)

        expect(component).to be_destroyed
      end
    end

    context "when there are proposals for the component" do
      before do
        create(:proposal, component: component)
      end

      it "raises an error" do
        expect do
          Decidim::Admin::DestroyComponent.call(component, current_user)
        end.to broadcast(:invalid)

        expect(component).not_to be_destroyed
      end
    end
  end

  describe "stats" do
    subject { current_stat[2] }

    let(:raw_stats) do
      Decidim.component_manifests.map do |component_manifest|
        component_manifest.stats.filter(name: stats_name).with_context(component).flat_map { |name, data| [component_manifest.name, name, data] }
      end
    end

    let(:stats) do
      raw_stats.select { |stat| stat[0] == :proposals }
    end

    let!(:proposal) { create :proposal }
    let(:component) { proposal.component }
    let!(:hidden_proposal) { create :proposal, component: component }
    let!(:draft_proposal) { create :proposal, :draft, component: component }
    let!(:withdrawn_proposal) { create :proposal, :withdrawn, component: component }
    let!(:moderation) { create :moderation, reportable: hidden_proposal, hidden_at: 1.day.ago }

    let(:current_stat) { stats.find { |stat| stat[1] == stats_name } }

    describe "proposals_count" do
      let(:stats_name) { :proposals_count }

      it "only counts published (except withdrawn) and not hidden proposals" do
        expect(Decidim::Proposals::Proposal.where(component: component).count).to eq 4
        expect(subject).to eq 1
      end
    end

    describe "votes_count" do
      let(:stats_name) { :votes_count }

      before do
        create_list :proposal_vote, 2, proposal: proposal
        create_list :proposal_vote, 3, proposal: hidden_proposal
      end

      it "counts the votes from visible proposals" do
        expect(Decidim::Proposals::ProposalVote.count).to eq 5
        expect(subject).to eq 2
      end
    end

    describe "endorsements_count" do
      let(:stats_name) { :endorsements_count }

      before do
        create_list :proposal_endorsement, 2, proposal: proposal
        create_list :proposal_endorsement, 3, proposal: hidden_proposal
      end

      it "counts the endorsements from visible proposals" do
        expect(Decidim::Proposals::ProposalEndorsement.count).to eq 5
        expect(subject).to eq 2
      end
    end

    describe "comments_count" do
      let(:stats_name) { :comments_count }

      before do
        create_list :comment, 2, commentable: proposal
        create_list :comment, 3, commentable: hidden_proposal
      end

      it "counts the comments from visible proposals" do
        expect(Decidim::Comments::Comment.count).to eq 5
        expect(subject).to eq 2
      end
    end
  end
end
