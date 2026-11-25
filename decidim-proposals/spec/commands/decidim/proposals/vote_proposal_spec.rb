# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Proposals
    describe VoteProposal do
      describe "call" do
        let(:proposal) { create(:proposal) }
        let(:current_user) { create(:user, organization: proposal.component.organization) }
        let(:command) { described_class.new(proposal, current_user) }

        context "with normal conditions" do
          it "broadcasts ok" do
            expect { command.call }.to broadcast(:ok)
          end

          it "creates a new vote for the proposal" do
            expect do
              command.call
            end.to change(ProposalVote, :count).by(1)
          end
        end

        context "when the vote is not valid" do
          before do
            # rubocop:disable-next RSpec/AnyInstance
            allow_any_instance_of(ProposalVote).to receive(:valid?).and_return(false)
          end

          it "broadcasts invalid" do
            expect { command.call }.to broadcast(:invalid)
          end

          it "does not create a new vote for the proposal" do
            expect do
              command.call
            end.not_to change(ProposalVote, :count)
          end
        end

        context "when the threshold have been reached" do
          before do
            allow(proposal).to receive(:maximum_votes_reached?).and_return(true)
          end

          it "broadcasts invalid" do
            expect { command.call }.to broadcast(:invalid)
          end
        end

        context "when the proposal is full according to the final votes but the counter cache is stale" do
          before do
            proposal.component[:settings]["global"] = { threshold_per_proposal: 10 }
            proposal.component.save!
            create_list(:proposal_vote, 10, proposal:)
            proposal.update!(proposal_votes_count: 0)
          end

          it "broadcasts invalid" do
            expect { command.call }.to broadcast(:invalid)
          end
        end

        it "rechecks the vote limit after locking the proposal and before saving the vote" do
          proposal.component[:settings]["global"] = { threshold_per_proposal: 10 }
          proposal.component.save!

          queries = []
          callback = ->(_name, _start, _finish, _id, payload) { queries << payload[:sql] unless payload[:cached] || payload[:name] == "SCHEMA" }

          ActiveSupport::Notifications.subscribed(callback, "sql.active_record") { command.call }

          lock_index = queries.index { |sql| sql.include?("FOR UPDATE") && sql.include?("decidim_proposals_proposals") }
          count_index = queries.index { |sql| sql.include?("COUNT(*)") && sql.include?("decidim_proposals_proposal_votes") }
          insert_index = queries.index { |sql| sql.include?("INSERT INTO \"decidim_proposals_proposal_votes\"") }

          expect(lock_index).to be_present
          expect(count_index).to be_present
          expect(insert_index).to be_present
          expect(lock_index).to be < count_index
          expect(count_index).to be < insert_index
        end

        context "when concurrent votes are submitted for the last available vote" do
          include_context "with concurrency"

          let!(:proposal) { create(:proposal) }
          let(:users) { create_list(:user, 2, organization: proposal.component.organization) }

          before do
            proposal.component[:settings]["global"] = { threshold_per_proposal: 1 }
            proposal.component.save!
          end

          it "only saves one vote" do
            proposal_id = proposal.id
            gate = Queue.new

            threads = users.map do |user|
              Thread.new do
                ActiveRecord::Base.connection_pool.with_connection do
                  gate.pop
                  locked_proposal = Decidim::Proposals::Proposal.find(proposal_id)
                  described_class.new(locked_proposal, user).call
                end
              end
            end

            2.times { gate << true }
            threads.each(&:join)

            expect(Decidim::Proposals::ProposalVote.where(decidim_proposal_id: proposal_id).count).to eq(1)
          end
        end

        context "when the threshold have been reached but proposal can accumulate more votes" do
          before do
            allow(proposal).to receive(:maximum_votes_reached?).and_return(true)
            allow(proposal).to receive(:can_accumulate_votes_beyond_threshold).and_return(true)
          end

          it "creates a new vote for the proposal" do
            expect do
              command.call
            end.to change(ProposalVote, :count).by(1)
          end
        end
      end
    end
  end
end
