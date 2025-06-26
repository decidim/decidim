# frozen_string_literal: true

require "spec_helper"

module Decidim::Elections
  describe ElectionStatus do
    subject(:status) { described_class.new(election) }

    let(:now) { Time.current }

    describe "#started?" do
      let(:election) { build(:election, start_at: now - 1.day) }

      it { expect(status.started?).to be true }

      context "when start_at is nil" do
        let(:election) { build(:election, start_at: nil) }

        it { expect(status.started?).to be false }
      end

      context "when start_at is in the future" do
        let(:election) { build(:election, start_at: now + 1.day) }

        it { expect(status.started?).to be false }
      end
    end

    describe "#vote_ended?" do
      let(:election) { build(:election, end_at: now + 1.day) }

      it { expect(status.vote_ended?).to be false }

      context "when in the past" do
        let(:election) { build(:election, end_at: now - 1.day) }

        it { expect(status.vote_ended?).to be true }
      end

      context "when end_at is nil" do
        let(:election) { build(:election, end_at: nil) }

        it { expect(status.vote_ended?).to be false }
      end
    end

    describe "#ongoing?" do
      let(:election) { build(:election, start_at: now - 1.day, end_at: now + 1.day) }

      it { expect(status.ongoing?).to be true }

      context "when not started" do
        let(:election) { build(:election, start_at: now + 1.day, end_at: now + 2.days) }

        it { expect(status.ongoing?).to be false }
      end

      context "when vote ended" do
        let(:election) { build(:election, start_at: now - 3.days, end_at: now - 1.day) }

        it { expect(status.ongoing?).to be false }
      end
    end

    describe "#scheduled?" do
      let(:election) { build(:election, published_at: now, start_at: now + 1.day, end_at: now + 2.days) }

      it { expect(status.scheduled?).to be true }

      context "when unpublished" do
        let(:election) { build(:election, published_at: nil, start_at: now + 1.day, end_at: now + 2.days) }

        it { expect(status.scheduled?).to be false }
      end
    end

    describe "#ready_to_publish_results?" do
      let(:election) { build(:election, results_availability: "after_end", end_at: now - 1.day, published_results_at: nil) }

      it { expect(status.ready_to_publish_results?).to be true }

      context "when already published" do
        let(:election) { build(:election, results_availability: "after_end", end_at: now - 1.day, published_results_at: now) }

        it { expect(status.ready_to_publish_results?).to be false }
      end
    end

    describe "#results_published?" do
      context "when real_time with ended vote" do
        let(:election) { build(:election, results_availability: "real_time", end_at: now - 1.day) }

        it { expect(status.results_published?).to be true }
      end

      context "when after_end with published results" do
        let(:election) { build(:election, results_availability: "after_end", published_results_at: now) }

        it { expect(status.results_published?).to be true }
      end

      context "when per_question with all published" do
        let(:election) { create(:election, results_availability: "per_question") }
        let!(:first_question) { create(:election_question, election:, published_results_at: now) }
        let!(:second_question) { create(:election_question, election:, published_results_at: now) }

        it { expect(status.results_published?).to be true }
      end

      context "when per_question with some not published" do
        let(:election) { create(:election, results_availability: "per_question") }
        let!(:first_question) { create(:election_question, election:, published_results_at: now) }
        let!(:second_question) { create(:election_question, election:, published_results_at: nil) }

        it { expect(status.results_published?).to be false }
      end
    end

    describe "#current_status" do
      context "when per_question and ongoing" do
        let(:election) { create(:election, results_availability: "per_question", start_at: now - 1.day, end_at: now + 1.day, published_at: now) }
        let!(:first_question) { create(:election_question, election:, published_results_at: now) }
        let!(:second_question) { create(:election_question, election:, published_results_at: nil) }

        it { expect(status.current_status).to eq(election_status: :ongoing, question_status: :open_1) } # rubocop:disable Naming/VariableNumber
      end

      context "when after_end with results published" do
        let(:election) { build(:election, results_availability: "after_end", end_at: now - 1.day, published_results_at: now) }

        it { expect(status.current_status).to eq(:results_published) }
      end

      context "when after_end with vote ended and no results" do
        let(:election) { build(:election, results_availability: "after_end", end_at: now - 1.day, published_results_at: nil) }

        it { expect(status.current_status).to eq(:ended) }
      end

      context "when real_time and ongoing" do
        let(:election) { build(:election, results_availability: "real_time", start_at: now - 1.day, end_at: now + 1.day) }

        it { expect(status.current_status).to eq(:ongoing) }
      end

      context "when scheduled" do
        let(:election) { build(:election, start_at: now + 1.day, end_at: now + 2.days, published_at: now) }

        it { expect(status.current_status).to eq(:scheduled) }
      end
    end

    describe "#localized_status" do
      let(:election) { build(:election, results_availability: "real_time", start_at: now - 1.day, end_at: now + 1.day) }

      it { expect(status.localized_status).to be_a(String) }
    end

    describe "#current_question_status" do
      let(:election) { create(:election, results_availability: "per_question") }
      let!(:first_question) { create(:election_question, election:, published_results_at: now) }
      let!(:second_question) { create(:election_question, election:, published_results_at: nil) }

      it { expect(status.current_question_status).to eq(:open_1) } # rubocop:disable Naming/VariableNumber
    end
  end
end
