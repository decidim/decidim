# frozen_string_literal: true
require "spec_helper"

module Decidim
  module Surveys
    describe SurveyAnswer do
      let(:organization) { create(:organization) }
      let(:user) { create(:user, organization: organization) }
      let(:participatory_process) { create(:participatory_process, organization: organization) }
      let(:feature) { create(:surveys_feature, participatory_process: participatory_process) }
      let(:survey) { create(:survey, feature: feature) }
      let(:survey_question) { create(:survey_question, survey: survey) }
      let(:survey_answer) { create(:survey_answer, survey: survey, question: survey_question, user: user) }
      subject { survey_answer }

      it { is_expected.to be_valid }

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
    end
  end
end
