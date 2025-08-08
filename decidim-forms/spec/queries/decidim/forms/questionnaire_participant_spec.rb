# frozen_string_literal: true

require "spec_helper"

describe Decidim::Forms::QuestionnaireParticipant do
  subject { described_class.new(questionnaire, session_token) }

  let!(:questionnaire) { create(:questionnaire) }
  let!(:user) { create(:user, organization: questionnaire.questionnaire_for.organization) }
  let!(:questions) { 3.downto(1).map { |n| create(:questionnaire_question, questionnaire:, position: n) } }
  let!(:responses) { questions.map { |question| create(:response, user:, questionnaire:, question:) } }
  let!(:session_token) { responses.first.session_token }

  it "returns the user info for a questionnaire participant by session_token" do
    result = subject.query

    expect(result.session_token).to eq(responses.first.session_token)
    expect(result.ip_hash).to eq(responses.first.ip_hash)
    expect(result.decidim_user_id).to eq(responses.first.decidim_user_id)
  end
end
