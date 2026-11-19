# frozen_string_literal: true

require "spec_helper"

module Decidim
  module CollaborativeTexts
    describe VoteSuggestion do
      subject(:command) { described_class.new(suggestion, author, weight:) }

      let(:suggestion) { create(:collaborative_text_suggestion) }
      let(:author) { create(:user, :confirmed, organization: suggestion.organization) }
      let(:weight) { 1 }

      describe "when the vote is created" do
        it "broadcasts ok" do
          expect { command.call }.to broadcast(:ok)
        end

        it "creates a vote" do
          expect { command.call }.to change(SuggestionVote, :count).by(1)
          expect(suggestion.reload).to be_up_voted_by(author)
        end
      end

      describe "when the same vote is submitted again" do
        before { create(:collaborative_text_suggestion_vote, suggestion:, author:, weight: 1) }

        it "removes the vote" do
          expect { command.call }.to change(SuggestionVote, :count).by(-1)
          expect(suggestion.reload).not_to be_up_voted_by(author)
        end
      end

      describe "when the user changes the vote" do
        before { create(:collaborative_text_suggestion_vote, suggestion:, author:, weight: 1) }

        let(:weight) { -1 }

        it "replaces the vote" do
          expect { command.call }.not_to change(SuggestionVote, :count)
          expect(suggestion.reload).to be_down_voted_by(author)
          expect(suggestion).not_to be_up_voted_by(author)
        end
      end

      describe "when the weight is invalid" do
        let(:weight) { 0 }

        it "broadcasts invalid" do
          expect { command.call }.to broadcast(:invalid)
        end

        it "does not create a vote" do
          expect { command.call }.not_to change(SuggestionVote, :count)
        end
      end

      describe "when the author is not in the same organization" do
        let(:author) { create(:user, :confirmed) }

        it "broadcasts invalid" do
          expect { command.call }.to broadcast(:invalid)
        end

        it "does not create a vote" do
          expect { command.call }.not_to change(SuggestionVote, :count)
        end
      end

      context "when concurrent votes are submitted" do
        include_context "with concurrency"

        let!(:suggestion) { create(:collaborative_text_suggestion) }
        let(:users) { create_list(:user, 2, :confirmed, organization: suggestion.organization) }

        it "records all the votes" do
          suggestion_id = suggestion.id
          gate = Queue.new

          threads = users.map do |user|
            Thread.new do
              ActiveRecord::Base.connection_pool.with_connection do
                gate.pop
                described_class.new(Decidim::CollaborativeTexts::Suggestion.find(suggestion_id), user, weight: 1).call
              end
            end
          end

          2.times { gate << true }
          threads.each(&:join)

          expect(SuggestionVote.where(suggestion_id:).count).to eq(2)
        end
      end
    end
  end
end
