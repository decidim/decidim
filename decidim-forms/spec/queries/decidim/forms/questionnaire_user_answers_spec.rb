# frozen_string_literal: true

require "spec_helper"

describe Decidim::Forms::QuestionnaireUserAnswers do
  subject { described_class.new(questionnaire) }

  let!(:questionnaire) { create(:questionnaire) }
  let!(:user1) { create(:user, organization: questionnaire.questionnaire_for.organization) }
  let!(:user2) { create(:user, organization: questionnaire.questionnaire_for.organization) }
  let!(:questions) do
    [
      create(:questionnaire_question, questionnaire: questionnaire, position: 3),
      create(:questionnaire_question, :separator, questionnaire: questionnaire, position: 2),
      create(:questionnaire_question, :title_and_description, questionnaire: questionnaire, position: 4),
      create(:questionnaire_question, questionnaire: questionnaire, position: 1)
    ]
  end
  let!(:answers_user1) { questions.map { |question| create :answer, user: user1, questionnaire: questionnaire, question: question } }
  let!(:answers_user2) { questions.map { |question| create :answer, user: user2, questionnaire: questionnaire, question: question } }

  it "returns the user answers for each user without the separators and title-and-descriptions" do
    result = subject.query

    expect(result).to contain_exactly([answers_user1.last, answers_user1.first], [answers_user2.last, answers_user2.first])
  end
end
