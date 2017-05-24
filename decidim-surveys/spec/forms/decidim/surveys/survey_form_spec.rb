# coding: utf-8
# frozen_string_literal: true
require "spec_helper"

module Decidim
  module Surveys
    describe SurveyForm do
      let!(:survey) { create(:survey) }
      let!(:survey_question) { create(:survey_question, survey: survey) }

      subject do
        described_class.from_model(survey).with_context(current_feature: survey.feature)
      end

      it "builds empty answers for each question" do
        expect(subject.answers.length).to eq(1)
      end

      context "when everything is OK" do
        it { is_expected.to be_valid }
      end
    end
  end
end
