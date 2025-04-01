# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Proposals
    describe ProposalVotesHelper do
      let(:organization) { create(:organization) }
      let(:limit) { 10 }
      let(:votes_enabled) { true }
      let(:proposal_component) { create(:proposal_component, organization:) }
      let(:user) { create(:user, organization:) }

      before do
        allow(helper).to receive(:current_user).and_return(user)
        allow(helper).to receive(:current_component).and_return(proposal_component)
        allow(helper).to receive(:current_settings).and_return(double(votes_enabled?: votes_enabled))
        allow(helper).to receive(:component_settings).and_return(double(vote_limit: limit))
      end

      describe "#vote_limit_enabled?" do
        context "when the current_settings vote_limit is less or equal 0" do
          let(:limit) { 0 }

          it "returns false" do
            expect(helper).not_to be_vote_limit_enabled
          end
        end

        context "when the current_settings vote_limit is greater than 0" do
          it "returns true" do
            expect(helper).to be_vote_limit_enabled
          end
        end
      end

      describe "#proposal_voted_by_user?" do
        it "returns false if the user has not voted on the proposal" do
          proposal = create(:proposal, component: proposal_component)
          create(:proposal_vote, proposal:)

          expect(helper).not_to be_proposal_voted_by_user(proposal)
        end

        it "returns true if the user has voted on the proposal" do
          proposal = create(:proposal, component: proposal_component)
          create(:proposal_vote, author: user, proposal:)

          expect(helper).to be_proposal_voted_by_user(proposal)
        end
      end

      describe "#remaining_votes_count_for" do
        it "returns the remaining votes for a user based on the component votes limit" do
          proposal = create(:proposal, component: proposal_component)
          create(:proposal_vote, author: user, proposal:)

          expect(helper.remaining_votes_count_for_user).to eq(9)
        end
      end

      describe "#remaining_minimum_votes_count_for" do
        subject { helper.remaining_minimum_votes_count_for_user }

        let(:minimum_votes) { 5 }

        before do
          allow(helper).to receive(:current_user).and_return(user)
          allow(helper).to receive(:vote_limit_enabled?).and_return(vote_limit_enabled)
          allow(helper).to receive(:component_settings).and_return(double(minimum_votes_per_user: minimum_votes))
        end

        context "when the vote limit is not enabled" do
          let(:vote_limit_enabled) { false }

          before do
            allow(helper).to receive(:minimum_votes_per_user_enabled?).and_return(false)
          end

          it "returns 0" do
            expect(subject).to eq(0)
          end
        end

        context "when the vote limit is enabled" do
          let(:vote_limit_enabled) { true }

          context "when the user has not cast any votes" do
            it "returns the minimum votes per user" do
              expect(subject).to eq(minimum_votes)
            end
          end

          context "when the user has cast some votes" do
            before do
              proposals = create_list(:proposal, 3, component: proposal_component)
              proposals.each { |proposal| create(:proposal_vote, author: user, proposal:) }
            end

            it "returns the remaining minimum votes" do
              expect(subject).to eq(2)
            end
          end

          context "when the user has cast enough votes to meet or exceed the minimum" do
            before do
              proposals = create_list(:proposal, 5, component: proposal_component)
              proposals.each { |proposal| create(:proposal_vote, author: user, proposal:) }
            end

            it "returns 0, as the minimum has been met" do
              expect(subject).to eq(0)
            end
          end
        end
      end
    end
  end
end
