# frozen_string_literal: true

require "spec_helper"

describe Decidim::Meetings::Engine do
  it_behaves_like "clean engine"

  describe "decidim_meetings.authorization_transfer" do
    include_context "authorization transfer"

    let(:component) { create(:meeting_component, organization:) }
    let(:poll_meeting) { create(:meeting, component:) }
    let(:questionnaire) { create(:meetings_poll_questionnaire, questionnaire_for: create(:poll, meeting: poll_meeting)) }
    let(:original_records) do
      {
        meetings: create_list(:meeting, 3, component:, author: original_user),
        registrations: create_list(:registration, 5, user: original_user),
        responses: create_list(:meetings_poll_response, 10, questionnaire:, user: original_user)
      }
    end
    let(:transferred_meetings) { Decidim::Meetings::Meeting.where(author: target_user).order(:id) }
    let(:transferred_registrations) { Decidim::Meetings::Registration.where(user: target_user).order(:id) }
    let(:transferred_responses) { Decidim::Meetings::Response.where(user: target_user).order(:id) }

    it "handles authorization transfer correctly" do
      expect(transferred_meetings.count).to eq(3)
      expect(transferred_registrations.count).to eq(5)
      expect(transferred_responses.count).to eq(10)
      expect(transfer.records.count).to eq(18)
      expect(transferred_resources).to eq(transferred_meetings + transferred_registrations + transferred_responses)
    end
  end
end
