# frozen_string_literal: true

require "spec_helper"

describe Decidim::Forms::QuestionnaireUserAnswers do
  subject { described_class.new(survey) }

  let!(:survey) { create(:survey) }
  let!(:user_1) { create(:user, organization: survey.component.organization) }
  let!(:user_2) { create(:user, organization: survey.component.organization) }
  let!(:survey_questions) { 3.downto(1).map { |n| create :survey_question, survey: survey, position: n } }
  let!(:survey_answers_user_1) { survey_questions.map { |question| create :survey_answer, user: user_1, survey: survey, question: question } }
  let!(:survey_answers_user_2) { survey_questions.map { |question| create :survey_answer, user: user_2, survey: survey, question: question } }

  it "returns the user answers for each user" do
    result = subject.query

    expect(result).to contain_exactly(
      survey_answers_user_1.sort { |answer| answer.question.position },
      survey_answers_user_2.sort { |answer| answer.question.position }
    )
  end
end
