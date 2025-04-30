# frozen_string_literal: true

require "spec_helper"

describe Decidim::Forms::QuestionnaireUserResponses do
  subject { described_class.new(questionnaire) }

  let!(:questionnaire) { create(:questionnaire) }
  let!(:user1) { create(:user, organization: questionnaire.questionnaire_for.organization) }
  let!(:user2) { create(:user, organization: questionnaire.questionnaire_for.organization) }
  let!(:questions) do
    [
      create(:questionnaire_question, questionnaire:, position: 3),
      create(:questionnaire_question, :separator, questionnaire:, position: 2),
      create(:questionnaire_question, :title_and_description, questionnaire:, position: 4),
      create(:questionnaire_question, questionnaire:, position: 1)
    ]
  end
  let!(:responses_user1) { questions.map { |question| create(:response, user: user1, questionnaire:, question:) } }
  let!(:responses_user2) { questions.map { |question| create(:response, user: user2, questionnaire:, question:) } }

  it "returns the user responses for each user without the separators and title-and-descriptions" do
    result = subject.query

    expect(result).to contain_exactly([responses_user1.last, responses_user1.first], [responses_user2.last, responses_user2.first])
  end
end
