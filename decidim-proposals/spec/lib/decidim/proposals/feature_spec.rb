# frozen_string_literal: true

require "spec_helper"

describe "Proposals feature" do # rubocop:disable RSpec/DescribeClass
  let!(:feature) { create(:proposal_feature) }

  describe "on destroy" do
    context "when there are no proposals for the feature" do
      it "destroys the feature" do
        expect do
          Decidim::Admin::DestroyFeature.call(feature)
        end.to change { Decidim::Feature.count }.by(-1)

        expect(feature).to be_destroyed
      end
    end

    context "when there are proposals for the feature" do
      before do
        create(:proposal, feature: feature)
      end

      it "raises an error" do
        expect do
          Decidim::Admin::DestroyFeature.call(feature)
        end.to broadcast(:invalid)

        expect(feature).not_to be_destroyed
      end
    end
  end

  describe "stats" do
    subject { current_stat[2] }

    let(:raw_stats) do
      Decidim.feature_manifests.map do |feature_manifest|
        feature_manifest.stats.filter(name: stats_name).with_context(feature).flat_map { |name, data| [feature_manifest.name, name, data] }
      end
    end

    let(:stats) do
      raw_stats.select { |stat| stat[0] == :proposals }
    end

    let!(:proposal) { create :proposal }
    let(:feature) { proposal.feature }
    let!(:hidden_proposal) { create :proposal, feature: feature }
    let!(:moderation) { create :moderation, reportable: hidden_proposal, hidden_at: 1.day.ago }

    let(:current_stat) { stats.find { |stat| stat[1] == stats_name } }

    describe "proposals_count" do
      let(:stats_name) { :proposals_count }

      it "only counts not hidden proposals" do
        expect(Decidim::Proposals::Proposal.where(feature: feature).count).to eq 2
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
