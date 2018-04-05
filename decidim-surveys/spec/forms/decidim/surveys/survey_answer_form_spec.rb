# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Surveys
    describe SurveyAnswerForm do
      subject do
        described_class.from_model(survey_answer).with_context(current_component: survey.component)
      end

      let!(:survey) { create(:survey) }
      let!(:user) { create(:user, organization: survey.component.participatory_space.organization) }
      let!(:survey_question) { create(:survey_question, survey: survey) }
      let!(:survey_answer) { create(:survey_answer, user: user, survey: survey, question: survey_question) }

      context "when everything is OK" do
        it { is_expected.to be_valid }
      end

      context "when the question is mandatory" do
        let!(:survey_question) { create(:survey_question, survey: survey, mandatory: true) }

        it "is not valid if body is not present" do
          subject.body = nil
          expect(subject).not_to be_valid
        end

        it "is not valid if body entries are all blank" do
          subject.body = [""]
          expect(subject).not_to be_valid
        end
      end

      context "when the question has max_choices set" do
        let!(:survey_question) { create(:survey_question, survey: survey, max_choices: 2) }

        it "is valid if few enough answers checked" do
          subject.body = %w(foo bar)
          expect(subject).to be_valid
        end

        it "is not valid if too many answers checked" do
          subject.body = %w(foo bar baz)
          expect(subject).not_to be_valid
        end
      end
    end
  end
end
