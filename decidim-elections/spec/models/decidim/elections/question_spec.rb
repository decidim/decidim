# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Elections
    describe Question do
      subject { question }

      let(:election) { create(:election) }
      let(:question) { create(:election_question, :with_response_options, election:) }

      it { is_expected.to be_valid }
      it { is_expected.to be_versioned }

      it "has an association with election" do
        expect(subject.election).to eq(election)
      end

      it "has many response options" do
        expect(subject.response_options.count).to be_positive
      end

      describe "validations" do
        context "when question_type is invalid" do
          let(:question) { build(:election_question, election:, question_type: "invalid") }

          it { is_expected.not_to be_valid }
        end

        context "when body is missing" do
          let(:question) { build(:election_question, election:, body: {}) }

          it { is_expected.not_to be_valid }
        end
      end

      describe "#presenter" do
        it "returns a presenter instance" do
          expect(subject.presenter).to be_a(Decidim::Elections::QuestionPresenter)
        end
      end

      describe "#voting_enabled?" do
        let(:question) { build(:election_question, :voting_enabled) }

        it { expect(subject.voting_enabled?).to be true }

        context "when voting_enabled_at is nil" do
          let(:question) { build(:election_question) }

          it { expect(subject.voting_enabled?).to be false }
        end
      end

      describe "#can_enable_voting?" do
        let(:question) { build(:election_question, voting_enabled_at:, election:) }
        let(:voting_enabled_at) { Time.current }
        let(:election) { build(:election) }

        it { is_expected.not_to be_can_enable_voting }

        context "when voting is not enabled" do
          let(:voting_enabled_at) { nil }

          it { is_expected.not_to be_can_enable_voting }
        end

        context "when election is ongoing" do
          let(:election) { build(:election, :ongoing) }

          it { is_expected.not_to be_can_enable_voting }

          context "when voting is not enabled" do
            let(:voting_enabled_at) { nil }

            it { is_expected.to be_can_enable_voting }
          end
        end
      end

      describe "#published_results?" do
        let(:question) { build(:election_question) }

        it { expect(subject.published_results?).to be false }

        context "when published_results_at is present" do
          let(:question) { build(:election_question, :results_published) }

          it { expect(subject.published_results?).to be true }
        end
      end

      describe "#publishable_results?" do
        let(:question) { build(:election_question, voting_enabled_at:, election:) }
        let(:voting_enabled_at) { Time.current }
        let(:election) { build(:election, results_availability:) }
        let(:results_availability) { "real_time" }

        it { is_expected.not_to be_publishable_results }

        context "when after_end results availability" do
          let(:results_availability) { "after_end" }

          it { is_expected.not_to be_publishable_results }

          context "when election is ready to publish results" do
            before { allow(election).to receive(:ready_to_publish_results?).and_return(true) }

            it { is_expected.to be_publishable_results }
          end
        end

        context "when per_question results availability" do
          let(:results_availability) { "per_question" }

          it { is_expected.to be_publishable_results }

          context "when already published results" do
            let(:question) { build(:election_question, :results_published, voting_enabled_at:, election:) }

            it { is_expected.not_to be_publishable_results }
          end

          context "when voting is not enabled" do
            let(:voting_enabled_at) { nil }

            it { is_expected.not_to be_publishable_results }
          end
        end
      end

      describe "#safe_responses" do
        let!(:another_question) { create(:election_question, :with_response_options, election:) }

        it "returns only responses for the current question" do
          response_ids = question.response_options.pluck(:id) + another_question.response_options.pluck(:id)
          expect(question.safe_responses(response_ids)).to eq(question.response_options)
        end

        it "returns only valid responses for single_option question type" do
          question.update!(question_type: "single_option")
          response_ids = question.response_options.pluck(:id)
          expect(question.safe_responses(response_ids)).to eq(question.response_options.where(id: response_ids.first))
        end
      end

      describe "#sibling_questions" do
        let!(:enabled_question) { create(:election_question, :voting_enabled, election:) }

        it "returns all questions of the election when per_question is false" do
          expect(question.sibling_questions.all).to contain_exactly(question, enabled_question)
        end

        context "when per_question is true" do
          before { election.update!(results_availability: "per_question") }

          it "returns only enabled questions of the election" do
            expect(question.sibling_questions.all).to eq([enabled_question])
          end
        end
      end

      describe "#next_question" do
        let!(:next_question) { create(:election_question, position: question.position + 1, election:) }

        it "returns the next question based on position" do
          expect(question.next_question).to eq(next_question)
        end

        context "when there is no next question" do
          let!(:next_question) { nil }

          it "returns nil" do
            expect(question.next_question).to be_nil
          end
        end
      end

      describe "#previous_question" do
        let!(:previous_question) { create(:election_question, position: question.position - 1, election:) }

        it "returns the previous question based on position" do
          expect(question.previous_question).to eq(previous_question)
        end

        context "when there is no previous question" do
          let!(:previous_question) { nil }

          it "returns nil" do
            expect(question.previous_question).to be_nil
          end
        end
      end

      context "when destroying" do
        before do
          question.save
        end

        it "destroys the question and its response options" do
          expect { question.destroy! }.to change(Decidim::Elections::Question, :count).by(-1)
          expect(ResponseOption.count).to be_zero
        end

        it "raises an error when trying to destroy with votes" do
          create(:election_vote, question:)
          expect { question.destroy! }.to raise_error(ActiveRecord::RecordNotDestroyed)
          expect(question.reload).to be_persisted
          expect(question.votes.count).to be_positive
        end
      end
    end
  end
end
