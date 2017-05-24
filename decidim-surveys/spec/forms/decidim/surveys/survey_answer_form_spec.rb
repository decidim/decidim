# coding: utf-8
# frozen_string_literal: true
require "spec_helper"

module Decidim
  module Surveys
    describe SurveyAnswerForm do
      let!(:survey) { create(:survey) }
      let!(:user) { create(:user, organization: survey.feature.participatory_process.organization) }
      let!(:survey_question) { create(:survey_question, survey: survey) }
      let!(:survey_answer) { create(:survey_answer, user: user, survey: survey, question: survey_question) }

      subject do
        described_class.from_model(survey_answer).with_context({
          current_feature: survey.feature
        })
      end

      context "when everything is OK" do
        it { is_expected.to be_valid }
      end

      context "when the question is mandatory" do
        let!(:survey_question) { create(:survey_question, survey: survey, mandatory: true) }

        it "is not valid if body is not present" do
          subject.body = ""
          expect(subject).not_to be_valid
        end
      end
    end
  end
end
