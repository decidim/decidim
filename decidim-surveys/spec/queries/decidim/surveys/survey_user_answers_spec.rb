# frozen_string_literal: true

require "spec_helper"

describe Decidim::Surveys::SurveyUserAnswers do
  let!(:survey) { create(:survey) }
  let!(:user_1) { create(:user, organization: survey.feature.organization) }
  let!(:user_2) { create(:user, organization: survey.feature.organization) }
  let!(:survey_questions) { 3.downto(1).map { |n| create :survey_question, survey: survey, position: n } }
  let!(:survey_answers_user_1) { survey_questions.map { |question| create :survey_answer, user: user_1, survey: survey, question: question } }
  let!(:survey_answers_user_2) { survey_questions.map { |question| create :survey_answer, user: user_2, survey: survey, question: question } }

  subject { described_class.new(survey) }

  it "returns the user answers for each user" do
    result = subject.query

    expect(result[0]).to eq(survey_answers_user_1.sort { |answer| answer.question.position })
    expect(result[1]).to eq(survey_answers_user_2.sort { |answer| answer.question.position })
  end
end
