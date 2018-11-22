# frozen_string_literal: true

require "spec_helper"

describe Decidim::Forms::QuestionnaireUserAnswers do
  subject { described_class.new(questionnaire) }

  let!(:questionnaire) { create(:questionnaire) }
  let!(:user_1) { create(:user, organization: questionnaire.questionnaire_for.organization) }
  let!(:user_2) { create(:user, organization: questionnaire.questionnaire_for.organization) }
  let!(:questions) { 3.downto(1).map { |n| create :questionnaire_question, questionnaire: questionnaire, position: n } }
  let!(:answers_user_1) { questions.map { |question| create :answer, user: user_1, questionnaire: questionnaire, question: question } }
  let!(:answers_user_2) { questions.map { |question| create :answer, user: user_2, questionnaire: questionnaire, question: question } }

  it "returns the user answers for each user" do
    result = subject.query

    expect(result).to contain_exactly(
      answers_user_1.sort { |answer| answer.question.position },
      answers_user_2.sort { |answer| answer.question.position }
    )
  end
end
