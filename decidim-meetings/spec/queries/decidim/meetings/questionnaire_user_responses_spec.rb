# frozen_string_literal: true

require "spec_helper"

describe Decidim::Meetings::QuestionnaireUserResponses do
  subject { described_class.new(questionnaire) }

  let(:current_organization) { create(:organization) }
  let(:user1) { create(:user, organization: meeting_component.organization) }
  let(:user2) { create(:user, organization: meeting_component.organization) }
  let(:meeting_component) { create(:meeting_component) }
  let(:meeting) { create(:meeting, component: meeting_component) }
  let(:poll) { create(:poll, meeting:) }
  let(:questionnaire) { create(:meetings_poll_questionnaire, questionnaire_for: poll) }
  let!(:questions) do
    [
      create(:meetings_poll_question, questionnaire:, position: 2),
      create(:meetings_poll_question, questionnaire:, position: 1)
    ]
  end
  let!(:responses_user1) { questions.map { |question| create(:meetings_poll_response, question:, user: user1, questionnaire:) } }
  let!(:responses_user2) { questions.map { |question| create(:meetings_poll_response, question:, user: user2, questionnaire:) } }

  it "returns the user responses for each user" do
    result = subject.query

    expect(result).to contain_exactly(
      [responses_user1.last, responses_user1.first],
      [responses_user2.last, responses_user2.first]
    )
  end
end
