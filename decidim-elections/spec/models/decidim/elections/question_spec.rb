# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Elections
    describe Question do
      subject { question }

      let(:election) { create(:election) }
      let(:question) { create(:election_question, election:) }

      it { is_expected.to be_valid }

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
        let(:question) { build(:election_question) }

        it { expect(subject.voting_enabled?).to be true }

        context "when voting_enabled_at is nil" do
          let(:question) { build(:election_question, voting_enabled: false) }

          it { expect(subject.voting_enabled?).to be false }
        end
      end

      describe "#can_enable_voting?" do
        let(:question) { build(:election_question, voting_enabled:, election:) }
        let(:voting_enabled) { true }
        let(:election) { build(:election) }

        it { is_expected.not_to be_can_enable_voting }

        context "when voting is not enabled" do
          let(:voting_enabled) { false }

          it { is_expected.not_to be_can_enable_voting }
        end

        context "when election is ongoing" do
          let(:election) { build(:election, :ongoing) }

          it { is_expected.not_to be_can_enable_voting }

          context "when voting is not enabled" do
            let(:voting_enabled) { false }

            it { is_expected.to be_can_enable_voting }
          end
        end
      end

      describe "#published_results?" do
        let(:question) { build(:election_question) }

        it { expect(subject.published_results?).to be false }

        context "when published_results_at is present" do
          let(:question) { build(:election_question, :published_results) }

          it { expect(subject.published_results?).to be true }
        end
      end

      describe "#publishable_results?" do
        let(:question) { build(:election_question, voting_enabled:, election:) }
        let(:voting_enabled) { true }
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
            let(:question) { build(:election_question, :published_results, voting_enabled:, election:) }

            it { is_expected.not_to be_publishable_results }
          end

          context "when voting is not enabled" do
            let(:voting_enabled) { false }

            it { is_expected.not_to be_publishable_results }
          end
        end
      end
    end
  end
end
