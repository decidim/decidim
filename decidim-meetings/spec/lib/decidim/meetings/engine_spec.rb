# frozen_string_literal: true

require "spec_helper"

describe Decidim::Meetings::Engine do
  describe "decidim_meetings.authorization_transfer" do
    include_context "authorization transfer"

    let(:component) { create(:meeting_component, organization: organization) }
    let(:poll_meeting) { create(:meeting, component: component) }
    let(:questionnaire) { create(:meetings_poll_questionnaire, questionnaire_for: create(:poll, meeting: poll_meeting)) }
    let(:original_records) do
      {
        meetings: create_list(:meeting, 3, component: component, author: original_user),
        registrations: create_list(:registration, 5, user: original_user),
        answers: create_list(:meetings_poll_answer, 10, questionnaire: questionnaire, user: original_user)
      }
    end
    let(:transferred_meetings) { Decidim::Meetings::Meeting.where(author: target_user).order(:id) }
    let(:transferred_registrations) { Decidim::Meetings::Registration.where(user: target_user).order(:id) }
    let(:transferred_answers) { Decidim::Meetings::Answer.where(user: target_user).order(:id) }

    it "handles authorization transfer correctly" do
      expect(transferred_meetings.count).to eq(3)
      expect(transferred_registrations.count).to eq(5)
      expect(transferred_answers.count).to eq(10)
      expect(transfer.records.count).to eq(18)
      expect(transferred_resources).to eq(transferred_answers + transferred_meetings + transferred_registrations)
    end
  end
end
