# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Surveys
    describe Survey do
      subject { survey }

      let(:survey) { create(:survey) }
      let!(:open_survey) { create(:survey, allow_responses: true, starts_at: 2.days.ago, ends_at: 1.day.from_now) }
      let!(:closed_survey) { create(:survey, allow_responses: false, starts_at: nil, ends_at: nil) }
      let!(:future_survey) { create(:survey, allow_responses: true, starts_at: 1.day.from_now, ends_at: nil) }
      let!(:past_survey) { create(:survey, allow_responses: true, starts_at: 5.days.ago, ends_at: 2.days.ago) }
      let!(:indefinite_survey) { create(:survey, allow_responses: true, starts_at: nil, ends_at: nil) }

      include_examples "has component"

      it { is_expected.to be_valid }

      context "without a component" do
        let(:survey) { build(:survey, component: nil) }

        it { is_expected.not_to be_valid }
      end

      context "without a valid component" do
        let(:survey) { build(:survey, component: build(:component, manifest_name: "proposals")) }

        it { is_expected.not_to be_valid }
      end

      it "has an associated component" do
        expect(survey.component).to be_a(Decidim::Component)
      end

      context "without a questionnaire" do
        let(:survey) { build(:survey, questionnaire: nil) }

        it { is_expected.not_to be_valid }
      end

      it "has an associated questionnaire" do
        expect(survey.questionnaire).to be_a(Decidim::Forms::Questionnaire)
      end

      describe "#open?" do
        subject { survey.open? }

        let(:component) { survey.component }

        before do
          survey.update!(starts_at:, ends_at:, allow_responses: true)
        end

        context "when neither starts_at or ends_at are defined" do
          let(:starts_at) { nil }
          let(:ends_at) { nil }

          it { is_expected.to be_truthy }
        end

        context "when starts_at is defined" do
          let(:ends_at) { nil }

          context "and it is a date in the past" do
            let(:starts_at) { 1.day.ago }

            it { is_expected.to be_truthy }
          end

          context "and it is a date in the future" do
            let(:starts_at) { 1.day.from_now }

            it { is_expected.to be_falsey }
          end
        end

        context "when ends_at is defined" do
          let(:starts_at) { nil }

          context "and it is a date in the past" do
            let(:ends_at) { 1.day.ago }

            it { is_expected.to be_falsey }
          end

          context "and it is a date in the future" do
            let(:ends_at) { 1.day.from_now }

            it { is_expected.to be_truthy }
          end
        end

        context "when both starts_at and ends_at are defined" do
          let(:starts_at) { 1.day.ago }

          context "and ends_at is a date in the past" do
            let(:ends_at) { 1.day.ago }

            it { is_expected.to be_falsey }
          end

          context "and ends_at is a date in the future" do
            let(:ends_at) { 1.day.from_now }

            it { is_expected.to be_truthy }
          end
        end
      end

      describe "#closed?" do
        subject { survey.closed? }

        let(:component) { survey.component }

        before do
          survey.update!(starts_at:, ends_at:, allow_responses: false)
        end

        context "when neither starts_at or ends_at are defined" do
          let(:starts_at) { nil }
          let(:ends_at) { nil }

          it { is_expected.to be_truthy }
        end

        context "when starts_at is defined" do
          let(:ends_at) { nil }

          context "and it is a date in the past" do
            let(:starts_at) { 1.day.ago }

            it { is_expected.to be_truthy }
          end

          context "and it is a date in the future" do
            let(:starts_at) { 1.day.from_now }

            it { is_expected.to be_truthy }
          end
        end

        context "when ends_at is defined" do
          let(:starts_at) { nil }

          context "and it is a date in the past" do
            let(:ends_at) { 1.day.ago }

            it { is_expected.to be_truthy }
          end

          context "and it is a date in the future" do
            let(:ends_at) { 1.day.from_now }

            it { is_expected.to be_truthy }
          end
        end

        context "when both starts_at and ends_at are defined" do
          let(:starts_at) { 1.day.ago }

          context "and ends_at is a date in the past" do
            let(:ends_at) { 1.day.ago }

            it { is_expected.to be_truthy }
          end

          context "and ends_at is a date in the future" do
            let(:ends_at) { 1.day.from_now }

            it { is_expected.to be_truthy }
          end
        end
      end

      describe "scopes" do
        describe ".open" do
          it "returns surveys that are currently open" do
            expect(Decidim::Surveys::Survey.open).to include(open_survey, indefinite_survey)
          end

          it "does not return surveys that are closed, in the future, or already finished" do
            expect(Decidim::Surveys::Survey.open).not_to include(closed_survey, future_survey, past_survey)
          end
        end

        describe ".closed" do
          it "returns surveys that are closed or past their end date" do
            expect(Decidim::Surveys::Survey.closed).to include(closed_survey, past_survey)
          end
        end
      end

      describe ".ransackable_attributes" do
        it "returns the correct ransackable attributes" do
          expected_attributes = %w(ends_at starts_at allow_responses)
          expect(described_class.ransackable_attributes).to eq(expected_attributes)
        end
      end

      describe ".log_presenter_class_for" do
        it "returns the correct presenter class for logs" do
          expect(described_class.log_presenter_class_for(nil)).to eq(Decidim::Surveys::AdminLog::SurveyPresenter)
        end
      end
    end
  end
end
