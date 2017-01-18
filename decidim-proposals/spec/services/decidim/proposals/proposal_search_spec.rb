require "spec_helper"

module Decidim
  module Proposals
    describe ProposalSearch do
      let(:feature) { create(:feature) }
      let(:user) { create(:user, organization: feature.organization) }
      let!(:proposal) { create(:proposal, feature: feature)}
      let(:page) { 1 }

      describe "results" do
        let(:random_seed) { 0.2 }
        let(:activity) { [] }
        let(:search_text) { nil }        

        subject do 
          described_class.new({
            feature: feature,
            page: page,
            random_seed: random_seed,
            activity: activity,
            search_text: search_text,
            current_user: user
          }).results
        end

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
          proposals = described_class.new({
            feature: feature,
            per_page: 2,
            page: page,
            random_seed: random_seed
          }).results

          expect(proposals.total_pages).to eq(2)
          expect(proposals.total_count).to eq(4)
        end

        describe "when the filter includes search_text" do
          let(:search_text) { "dog" }        
          
          it "returns the proposals containing the search in the title or the body" do
            create_list(:proposal, 3, feature: feature)
            create(:proposal, title: "A dog", feature: feature)            
            create(:proposal, body: "There is a dog in the office", feature: feature)

            expect(subject.total_count).to eq(2)            
          end
        end

        describe "when the filter includes activity" do
          let(:activity) { ["voted"] }

          it "returns the proposals voted by the user" do
            create_list(:proposal, 3, feature: feature)
            create(:proposal_vote, proposal: Proposal.first, author: user)

            expect(subject.total_count).to eq(1)            
          end
        end
      end

      describe "random_seed" do
        subject do
          described_class.new({
            feature: feature,
            page: page,
            random_seed: random_seed
          }).random_seed
        end

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
