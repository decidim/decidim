# frozen_string_literal: true
require "spec_helper"

module Decidim
  module Surveys
    describe Survey do
      let(:survey) { create(:survey) }
      subject { survey }

      include_examples "has feature"

      it { is_expected.to be_valid }

      it "has an association of questions" do
        subject.questions << create(:survey_question)
        subject.questions << create(:survey_question)
        expect(subject.questions.count).to eq(2)
      end

      context "without a feature" do
        let(:survey) { build :survey, feature: nil }

        it { is_expected.not_to be_valid }
      end

      context "without a valid feature" do
        let(:survey) { build :survey, feature: build(:feature, manifest_name: "proposals") }

        it { is_expected.not_to be_valid }
      end

      it "has an associated feature" do
        expect(survey.feature).to be_a(Decidim::Feature)
      end
    end
  end
end
