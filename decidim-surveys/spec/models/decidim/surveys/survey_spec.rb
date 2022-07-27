# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Surveys
    describe Survey do
      subject { survey }

      let(:survey) { create(:survey) }

      include_examples "has component"

      it { is_expected.to be_valid }

      context "without a component" do
        let(:survey) { build :survey, component: nil }

        it { is_expected.not_to be_valid }
      end

      context "without a valid component" do
        let(:survey) { build :survey, component: build(:component, manifest_name: "proposals") }

        it { is_expected.not_to be_valid }
      end

      it "has an associated component" do
        expect(survey.component).to be_a(Decidim::Component)
      end

      context "without a questionnaire" do
        let(:survey) { build :survey, questionnaire: nil }

        it { is_expected.not_to be_valid }
      end

      it "has an associated questionnaire" do
        expect(survey.questionnaire).to be_a(Decidim::Forms::Questionnaire)
      end

      describe "#open?" do
        subject { survey.open? }

        let(:component) { survey.component }

        before do
          component.settings = { starts_at:, ends_at: }
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
    end
  end
end
