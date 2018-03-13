# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Surveys
    describe Survey do
      subject { survey }

      let(:survey) { create(:survey) }

      include_examples "has component"

      it { is_expected.to be_valid }

      it "has an association of questions" do
        subject.questions << create(:survey_question)
        subject.questions << create(:survey_question)
        expect(subject.questions.count).to eq(2)
      end

      it "has an association of answers" do
        create(:survey_answer, survey: subject, user: create(:user, organization: survey.component.organization))
        create(:survey_answer, survey: subject, user: create(:user, organization: survey.component.organization))
        expect(subject.reload.answers.count).to eq(2)
      end

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

      describe "#questions_editable?" do
        it "returns false when survey has already answers" do
          create(:survey_answer, survey: survey)
          expect(subject.reload).not_to be_questions_editable
        end
      end

      describe "#answered_by?" do
        let!(:user) { create(:user, organization: survey.component.participatory_space.organization) }
        let!(:question) { create(:survey_question, survey: survey) }

        it "returns false if the given user has not answered the survey" do
          expect(survey).not_to be_answered_by(user)
        end

        it "returns true if the given user has answered the survey" do
          create(:survey_answer, survey: survey, question: question, user: user)
          expect(survey).to be_answered_by(user)
        end
      end
    end
  end
end
