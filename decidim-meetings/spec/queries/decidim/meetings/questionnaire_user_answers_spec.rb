# frozen_string_literal: true

require "spec_helper"

describe Decidim::Meetings::QuestionnaireUserAnswers do
  subject { described_class.new(questionnaire) }

  let(:current_organization) { create(:organization) }
  let(:user_1) { create :user, organization: meeting_component.organization }
  let(:user_2) { create :user, organization: meeting_component.organization }
  let(:meeting_component) { create :meeting_component }
  let(:meeting) { create :meeting, component: meeting_component }
  let(:poll) { create :poll, meeting: meeting }
  let(:questionnaire) { create :meetings_poll_questionnaire, questionnaire_for: poll }
  let!(:questions) do
    [
      create(:meetings_poll_question, questionnaire: questionnaire, position: 2),
      create(:meetings_poll_question, questionnaire: questionnaire, position: 1)
    ]
  end
  let!(:answers_user_1) { questions.map { |question| create(:meetings_poll_answer, question: question, user: user_1, questionnaire: questionnaire) } }
  let!(:answers_user_2) { questions.map { |question| create(:meetings_poll_answer, question: question, user: user_2, questionnaire: questionnaire) } }

  it "returns the user answers for each user" do
    result = subject.query

    expect(result).to contain_exactly(
      [answers_user_1.last, answers_user_1.first],
      [answers_user_2.last, answers_user_2.first]
    )
  end
end
