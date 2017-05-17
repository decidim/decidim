# frozen_string_literal: true
require "spec_helper"

module Decidim
  module Surveys
    describe SurveyQuestion do
      let(:survey) { create(:survey) }
      let(:survey_question) { create(:survey_question, survey: survey) }
      subject { survey_question }

      it { is_expected.to be_valid }

      it "has an association of survey" do
        expect(subject.survey).to eq(survey)
      end
    end
  end
end
