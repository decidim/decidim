# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Elections
    describe Election do
      subject { election }

      let(:election) { build(:election) }
      let(:organization) { election.component.organization }

      it { is_expected.to be_valid }
      it { is_expected.to act_as_paranoid }

      include_examples "has component"
      include_examples "resourceable"

      context "without a component" do
        let(:election) { build(:election, component: nil) }

        it { is_expected.not_to be_valid }
      end

      context "without a valid component" do
        let(:election) { build(:election, component: build(:component, manifest_name: "proposals")) }

        it { is_expected.not_to be_valid }
      end

      it "has an associated component" do
        expect(election.component).to be_a(Decidim::Component)
      end

      context "without a title" do
        let(:election) { build(:election, title: nil) }

        it { is_expected.not_to be_valid }
      end

      context "without a description" do
        let(:election) { build(:election, description: nil) }

        it { is_expected.to be_valid }
      end

      describe "#manual_start?" do
        it "returns true when start_at is nil" do
          election.start_at = nil
          expect(election.manual_start?).to be true
        end

        it "returns false when start_at is present" do
          election.start_at = Time.current
          expect(election.manual_start?).to be false
        end
      end

      describe "#auto_start?" do
        it "returns true when start_at is present" do
          election.start_at = Time.current
          expect(election.auto_start?).to be true
        end

        it "returns false when start_at is nil" do
          election.start_at = nil
          expect(election.auto_start?).to be false
        end
      end

      describe "associations" do
        it "has many questions" do
          election.save!
          create(:election_question, election: election)
          expect(election.questions.count).to eq(1)
        end
      end

      describe "results_availability enum" do
        it "accepts real_time, per_question, after_end" do
          %w(real_time per_question after_end).each do |val|
            election.results_availability = val
            expect(election.results_availability).to eq(val)
          end
        end

        it "raises error for invalid value" do
          expect { election.results_availability = "invalid" }.to raise_error(ArgumentError)
        end
      end

      describe "#presenter" do
        it "returns a presenter instance" do
          expect(election.presenter).to be_a(Decidim::Elections::ElectionPresenter)
        end
      end

      describe ".log_presenter_class_for" do
        it "returns the admin log presenter class" do
          expect(described_class.log_presenter_class_for(nil)).to eq(Decidim::Elections::AdminLog::ElectionPresenter)
        end
      end

      describe "#ordered_questions" do
        let(:election_with_questions) { create(:election) }
        let!(:first_question) { create(:election_question, election: election_with_questions, position: 1) }
        let!(:second_question) { create(:election_question, election: election_with_questions, position: 2) }

        it "returns questions ordered by position" do
          expect(election_with_questions.ordered_questions).to eq([first_question, second_question])
        end
      end

      describe "#per_question?" do
        let(:election_with_per_question) { build(:election, results_availability: "per_question") }
        let(:election_with_real_time) { build(:election, results_availability: "real_time") }

        it "returns true when results_availability is per_question" do
          expect(election_with_per_question.per_question?).to be true
        end

        it "returns false when results_availability is not per_question" do
          expect(election_with_real_time.per_question?).to be false
        end
      end

      describe "#results_publishable_for?" do
        let(:election_with_per_question) { create(:election, results_availability: "per_question") }
        let!(:publishable_question) { create(:election_question, election: election_with_per_question, voting_enabled_at: Time.current, published_results_at: nil) }
        let!(:published_question) { create(:election_question, election: election_with_per_question, voting_enabled_at: Time.current, published_results_at: Time.current) }

        it "returns true when the question is eligible for publication" do
          expect(election_with_per_question.results_publishable_for?(publishable_question)).to be true
        end

        it "returns false when the question already has published results" do
          expect(election_with_per_question.results_publishable_for?(published_question)).to be false
        end
      end

      describe "#next_question_to_enable" do
        before { election.save! }

        let!(:first_question) { create(:election_question, election:, position: 0, voting_enabled_at: Time.current, published_results_at: Time.current) }
        let!(:second_question) { create(:election_question, election:, position: 1, voting_enabled_at: nil, published_results_at: nil) }

        it "returns the first question not yet enabled or published" do
          expect(election.next_question_to_enable).to eq(second_question)
        end
      end

      describe "#can_enable_voting_for?" do
        before do
          election.update!(start_at: 1.day.ago, end_at: 1.day.from_now) # ongoing
        end

        let!(:first_question) { create(:election_question, election:, position: 0, voting_enabled_at: Time.current, published_results_at: Time.current) }
        let!(:second_question) { create(:election_question, election:, position: 1, voting_enabled_at: nil, published_results_at: nil) }

        it "returns true if previous question has published results and voting not yet enabled" do
          expect(election.can_enable_voting_for?(second_question)).to be true
        end

        it "returns false if question already has voting enabled" do
          second_question.update!(voting_enabled_at: Time.current)
          expect(election.can_enable_voting_for?(second_question)).to be false
        end

        it "returns false if previous question has no published results" do
          first_question.update!(published_results_at: nil)
          expect(election.can_enable_voting_for?(second_question)).to be false
        end

        it "returns false if election not ongoing" do
          election.update!(start_at: 2.days.from_now)
          expect(election.can_enable_voting_for?(second_question)).to be false
        end
      end
    end
  end
end
