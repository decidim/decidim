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

      context "without questions" do
        it "cannot be published" do
          survey.published_at = Time.current
          expect(survey).not_to be_valid
        end
      end

      context "with questions" do
        it "can be published" do
          create(:survey_question, survey: survey)
          survey.reload
          survey.published_at = Time.current
          expect(survey).to be_valid
        end
      end

      it "has an associated feature" do
        expect(survey.feature).to be_a(Decidim::Feature)
      end

      context "#published?" do
        it "returns true when published_at is not nil" do
          survey.published_at = Time.current
          expect(survey).to be_published
        end
      end

      context "#answered_by?" do
        let!(:user) { create(:user, organization: survey.feature.participatory_process.organization) }
        let!(:question) { create(:survey_question, survey: survey) }

        it "returns false if the given user has not answered the survey" do
          expect(survey.answered_by?(user)).to be_falsy
        end

        it "returns true if the given user has answered the survey" do
          create(:survey_answer, survey: survey, question: question, user: user)
          expect(survey.answered_by?(user)).to be_truthy
        end
      end
    end
  end
end
