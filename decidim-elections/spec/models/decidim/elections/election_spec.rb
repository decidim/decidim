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
    end
  end
end
