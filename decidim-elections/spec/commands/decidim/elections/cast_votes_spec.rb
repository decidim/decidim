# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Elections
    describe CastVotes do
      subject { described_class.new(election, data, voter_uid) }

      let(:election) { create(:election, :ongoing, :with_questions) }
      let(:voter_uid) { "gid://decidim/ElectionVoter/#{voter.id}" }
      let(:voter) { create(:election_voter, election:) }
      let(:data) do
        {
          election.questions.first.id.to_s => [election.questions.first.response_options.first.id.to_s],
          election.questions.second.id.to_s => [election.questions.second.response_options.first.id.to_s]
        }
      end

      it "it is valid" do
        expect { subject.call }.to broadcast(:ok)
      end

      it "casts votes for the given questions" do
        expect { subject.call }.to change { election.votes.count }.by(2)
        expect(election.votes.pluck(:voter_uid)).to include(voter_uid)
      end

      context "when the election is not ongoing" do
        let(:election) { create(:election, :finished, :with_questions) }

        it "does not allow casting votes" do
          expect { subject.call }.to broadcast(:invalid)
        end
      end

      context "when the voter_uid is blank" do
        let(:voter_uid) { "" }

        it "does not allow casting votes" do
          expect { subject.call }.to broadcast(:invalid)
        end
      end

      context "when the voter has already voted for all questions" do
        let!(:existing_votes) do
          create(:election_vote, question: election.questions.first, response_option: election.questions.first.response_options.last, voter_uid:)
          create(:election_vote, question: election.questions.second, response_option: election.questions.second.response_options.last, voter_uid:)
        end

        it "replaces the existing votes" do
          old_data = election.votes.pluck(:response_option_id)
          expect { subject.call }.not_to(change { election.votes.count })
          expect(election.votes.pluck(:voter_uid)).to include(voter_uid)
          expect(election.votes.pluck(:response_option_id)).not_to eq(old_data)
          expect(election.votes.pluck(:response_option_id)).to match_array(data.values.flatten.map(&:to_i))
        end
      end

      context "when multiple votes are cast for the same question" do
        let(:data) do
          {
            election.questions.first.id.to_s => [
              election.questions.first.response_options.first.id.to_s,
              election.questions.first.response_options.second.id.to_s
            ],
            election.questions.second.id.to_s => [election.questions.second.response_options.first.id.to_s]
          }
        end

        it "Cast all votes" do
          expect { subject.call }.to change { election.votes.count }.by(3)
          expect(election.votes.pluck(:response_option_id)).to contain_exactly(
            data[election.questions.first.id.to_s].first.to_i,
            data[election.questions.first.id.to_s].second.to_i,
            data[election.questions.second.id.to_s].first.to_i
          )
        end

        context "when the question type is single option" do
          before do
            election.questions.first.update!(question_type: "single_option")
          end

          it "does not allow casting multiple votes for the same question" do
            expect { subject.call }.to change { election.votes.count }.by(2)
            expect(election.votes.pluck(:response_option_id)).to contain_exactly(data[election.questions.first.id.to_s].first.to_i, data[election.questions.second.id.to_s].first.to_i)
          end
        end
      end

      context "when the voter removes a vote" do
        let!(:existing_votes) do
          create(:election_vote, question: election.questions.first, response_option: election.questions.first.response_options.last, voter_uid:)
          create(:election_vote, question: election.questions.second, response_option: election.questions.second.response_options.last, voter_uid:)
        end
        let(:data) do
          {
            election.questions.first.id.to_s => [election.questions.first.response_options.first.id.to_s],
            election.questions.second.id.to_s => []
          }
        end

        it "it is not allowed" do
          expect { subject.call }.to broadcast(:invalid)
        end

        it "does not change the number of votes" do
          expect { subject.call }.not_to(change { election.votes.count })
        end
      end

      context "when the voter has not voted for all questions" do
        let(:data) do
          {
            election.questions.first.id.to_s => [election.questions.first.response_options.first.id.to_s]
          }
        end

        it "does not allow casting votes" do
          expect { subject.call }.to broadcast(:invalid)
        end

        context "when election is per_question" do
          let(:election) { create(:election, :ongoing, :per_question, :with_questions) }

          it "allows casting votes for the questions answered" do
            expect { subject.call }.to broadcast(:ok)
            expect(election.votes.count).to eq(1)
            expect(election.votes.first.response_option_id).to eq(data.values.flatten.first.to_i)
          end

          context "and the question is not available" do
            let(:data) do
              {
                election.questions.first.id.to_s => [election.questions.first.response_options.first.id.to_s]
              }
            end

            before do
              election.questions.first.update!(voting_enabled_at: nil)
            end

            it "does not allow casting votes for the unavailable question" do
              expect { subject.call }.to broadcast(:invalid)
            end
          end
        end
      end

      context "when the data is invalid" do
        let(:data) do
          {
            election.questions.first.id.to_s => ["invalid_response_option_id"]
          }
        end

        it "does not allow casting votes" do
          expect { subject.call }.to broadcast(:invalid)
        end
      end

      context "when the election has no questions" do
        let(:election) { create(:election, :ongoing) }
        let(:data) { {} }

        it "does not allow casting votes" do
          expect { subject.call }.to broadcast(:invalid)
        end
      end
    end
  end
end
