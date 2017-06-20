# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Surveys
    describe SurveyQuestion do
      let(:survey) { create(:survey) }
      let(:question_type) { "short_answer" }
      let(:survey_question) { build(:survey_question, survey: survey, question_type: question_type) }
      subject { survey_question }

      it { is_expected.to be_valid }

      it "has an association of survey" do
        expect(subject.survey).to eq(survey)
      end

      context "when question type doesn't exists in allowed types" do
        let(:question_type) { "foo" }
        it { is_expected.not_to be_valid }
      end
    end
  end
end
