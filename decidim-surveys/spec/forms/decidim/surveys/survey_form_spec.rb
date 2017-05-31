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

      context "when tos_agreement is not accepted" do
        it { is_expected.not_to be_valid }
      end

      context "when tos_agreement is not accepted" do
        before do
          subject.tos_agreement = true
        end

        it { is_expected.to be_valid }
      end
    end
  end
end
