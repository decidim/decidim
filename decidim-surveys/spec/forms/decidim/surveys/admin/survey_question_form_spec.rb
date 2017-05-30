# coding: utf-8
# frozen_string_literal: true
require "spec_helper"

module Decidim
  module Surveys
    module Admin
      describe SurveyQuestionForm do
        let!(:survey) { create(:survey) }
        let!(:position) { 0 }
        let!(:question_type) { SurveyQuestion::TYPES.first }
        let!(:survey_question) { create(:survey_question, survey: survey, position: position, question_type: question_type) }

        subject do
          described_class.from_model(survey_question).with_context(current_feature: survey.feature)
        end

        context "when everything is OK" do
          it { is_expected.to be_valid }
        end

        context "when the position is not present" do
          let!(:position) { nil }

          it { is_expected.not_to be_valid }
        end

        context "when the question_type is not known" do
          let!(:question_type) { "foo" }

          it { is_expected.not_to be_valid }
        end
      end
    end
  end
end
