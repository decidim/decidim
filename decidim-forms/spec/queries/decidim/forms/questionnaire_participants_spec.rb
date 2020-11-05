# frozen_string_literal: true

require "spec_helper"

describe Decidim::Forms::QuestionnaireParticipants do
  subject { described_class.new(questionnaire) }

  let!(:questionnaire) { create(:questionnaire) }
  let!(:user_1) { create(:user, organization: questionnaire.questionnaire_for.organization) }
  let!(:user_2) { create(:user, organization: questionnaire.questionnaire_for.organization) }
  let!(:questions) { 3.downto(1).map { |n| create :questionnaire_question, questionnaire: questionnaire, position: n } }
  let!(:answers_user_1) { questions.map { |question| create :answer, user: user_1, questionnaire: questionnaire, question: question } }
  let!(:answers_user_2) { questions.map { |question| create :answer, user: user_2, questionnaire: questionnaire, question: question } }

  it "returns the user info for each participant" do
    result = subject.query.order(:session_token)

    user_1_info = result.find_by(decidim_user_id: user_1.id)
    user_2_info = result.find_by(decidim_user_id: user_2.id)

    expect(user_1_info.session_token).to eq(answers_user_1.first.session_token)
    expect(user_1_info.ip_hash).to eq(answers_user_1.first.ip_hash)
    expect(user_1_info.decidim_user_id).to eq(answers_user_1.first.decidim_user_id)

    expect(user_2_info.session_token).to eq(answers_user_2.first.session_token)
    expect(user_2_info.ip_hash).to eq(answers_user_2.first.ip_hash)
    expect(user_2_info.decidim_user_id).to eq(answers_user_2.first.decidim_user_id)
  end
end
