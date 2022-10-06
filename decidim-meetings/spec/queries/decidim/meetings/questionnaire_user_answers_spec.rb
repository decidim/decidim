# frozen_string_literal: true

require "spec_helper"

describe Decidim::Meetings::QuestionnaireUserAnswers do
  subject { described_class.new(questionnaire) }

  let(:current_organization) { create(:organization) }
  let(:user1) { create :user, organization: meeting_component.organization }
  let(:user2) { create :user, organization: meeting_component.organization }
  let(:meeting_component) { create :meeting_component }
  let(:meeting) { create :meeting, component: meeting_component }
  let(:poll) { create :poll, meeting: }
  let(:questionnaire) { create :meetings_poll_questionnaire, questionnaire_for: poll }
  let!(:questions) do
    [
      create(:meetings_poll_question, questionnaire:, position: 2),
      create(:meetings_poll_question, questionnaire:, position: 1)
    ]
  end
  let!(:answers_user1) { questions.map { |question| create(:meetings_poll_answer, question:, user: user1, questionnaire:) } }
  let!(:answers_user2) { questions.map { |question| create(:meetings_poll_answer, question:, user: user2, questionnaire:) } }

  it "returns the user answers for each user" do
    result = subject.query

    expect(result).to contain_exactly(
      [answers_user1.last, answers_user1.first],
      [answers_user2.last, answers_user2.first]
    )
  end
end
