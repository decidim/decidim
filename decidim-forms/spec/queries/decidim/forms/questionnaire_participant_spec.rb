# frozen_string_literal: true

require "spec_helper"

describe Decidim::Forms::QuestionnaireParticipant do
  subject { described_class.new(questionnaire, session_token) }

  let!(:questionnaire) { create(:questionnaire) }
  let!(:user) { create(:user, organization: questionnaire.questionnaire_for.organization) }
  let!(:questions) { 3.downto(1).map { |n| create :questionnaire_question, questionnaire:, position: n } }
  let!(:answers) { questions.map { |question| create :answer, user:, questionnaire:, question: } }
  let!(:session_token) { answers.first.session_token }

  it "returns the user info for a questionnaire participant by session_token" do
    result = subject.query

    expect(result.session_token).to eq(answers.first.session_token)
    expect(result.ip_hash).to eq(answers.first.ip_hash)
    expect(result.decidim_user_id).to eq(answers.first.decidim_user_id)
  end
end
