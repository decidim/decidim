# frozen_string_literal: true

require "spec_helper"

describe "Attended meetings badge" do
  let(:organization) { create(:organization) }
  let(:meeting) { create :meeting, registrations_enabled: true, available_slots: 20 }
  let(:user) { create :user, :confirmed, organization: meeting.organization }

  describe "reset" do
    it "resets the score to the amount of meetings the user has attended" do
      create(:registration, meeting:, user:)

      Decidim::Gamification.reset_badges(Decidim::User.where(id: user.id))
      expect(Decidim::Gamification.status_for(user, :attended_meetings).score).to eq(1)
    end
  end
end
