require "spec_helper"

module Decidim
  module Proposals
    describe ProposalSearch do
      let(:feature) { create(:feature) }
      let!(:proposal) { create(:proposal, feature: feature)}
      let(:page) { 1 }

      describe "proposals" do
        let(:random_seed) { 0.2 }

        subject { described_class.new(feature, page, random_seed).proposals }

        context "when given a random seed" do
          it "sets the seed at the database" do
            allow(Proposal.connection).to receive(:execute).with(anything)
            expect(Proposal.connection).to receive(:execute).with("SELECT setseed(0.2)").and_call_original
            subject
          end
        end

        it "only includes proposals from the given feature" do
          other_proposal = create(:proposal)

          expect(subject).to include(proposal)
          expect(subject).to_not include(other_proposal)
        end

        it "randomizes the order of proposals" do
            allow(Proposal.connection).to receive(:execute).with(anything)
            expect_any_instance_of(Decidim::Proposals::Proposal::ActiveRecord_Relation).to receive(:reorder).with("RANDOM()").and_call_original
            subject
        end

        it "filters the proposals per page" do
          create_list(:proposal, 3, feature: feature)
          proposals = described_class.new(feature, page, random_seed, 2).proposals

          expect(proposals.total_pages).to eq(2)
          expect(proposals.total_count).to eq(4)
        end
      end

      describe "random_seed" do
        subject { described_class.new(feature, page, random_seed).random_seed }

        context "without a given random seed" do
          let(:random_seed) { nil }

          it { is_expected.to be_within(1).of(0.0) }
        end

        context "with an invalid random seed" do
          let(:random_seed) { ["foo", 2, -10].sample }

          it { is_expected.to be_within(1).of(0.0) }
        end
      end
    end
  end
end
