# frozen_string_literal: true

require "spec_helper"

describe Decidim::Forms::QuestionnaireUserAnswers do
  subject { described_class.new(questionnaire) }

  let!(:questionnaire) { create(:questionnaire) }
  let!(:user_1) { create(:user, organization: questionnaire.questionnaire_for.organization) }
  let!(:user_2) { create(:user, organization: questionnaire.questionnaire_for.organization) }
  let!(:questions) do
    [
      create(:questionnaire_question, questionnaire: questionnaire, position: 3),
      create(:questionnaire_question, :separator, questionnaire: questionnaire, position: 2),
      create(:questionnaire_question, questionnaire: questionnaire, position: 1)
    ]
  end
  let!(:answers_user_1) { questions.map { |question| create :answer, user: user_1, questionnaire: questionnaire, question: question } }
  let!(:answers_user_2) { questions.map { |question| create :answer, user: user_2, questionnaire: questionnaire, question: question } }

  it "returns the user answers for each user without the separators" do
    result = subject.query

    expect(result).to contain_exactly(
      [answers_user_1.last, answers_user_1.first],
      [answers_user_2.last, answers_user_2.first]
    )
  end
end
