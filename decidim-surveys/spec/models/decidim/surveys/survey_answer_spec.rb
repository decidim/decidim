# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Surveys
    describe SurveyAnswer do
      subject { survey_answer }

      let(:organization) { create(:organization) }
      let(:user) { create(:user, organization: organization) }
      let(:participatory_process) { create(:participatory_process, organization: organization) }
      let(:component) { create(:surveys_component, participatory_space: participatory_process) }
      let(:survey) { create(:survey, component: component) }
      let(:survey_question) { create(:survey_question, survey: survey) }
      let(:survey_answer) { create(:survey_answer, survey: survey, question: survey_question, user: user) }

      it { is_expected.to be_valid }

      it "requires choices for mandatory multiple choice questions" do
        survey_answer.question.update!(question_type: "single_option", mandatory: true)
        survey_answer.choices = []
        expect(subject).not_to be_valid
      end

      it "has an association of survey" do
        expect(subject.survey).to eq(survey)
      end

      it "has an association of question" do
        expect(subject.question).to eq(survey_question)
      end

      it "has an association of user" do
        expect(subject.user).to eq(user)
      end

      context "when the user doesn't belong to the same organization" do
        it "is not valid" do
          subject.user = create(:user)
          expect(subject).not_to be_valid
        end
      end

      context "when question doesn't belong to the survey" do
        it "is not valid" do
          subject.question = create(:survey_question)
          expect(subject).not_to be_valid
        end
      end

      context "when question is mandatory" do
        let(:survey_question) { create(:survey_question, survey: survey, mandatory: true) }

        it "is not valid with an empty body" do
          subject.body = ""
          expect(subject).not_to be_valid
        end
      end
    end
  end
end
