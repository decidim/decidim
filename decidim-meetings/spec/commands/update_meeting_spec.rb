# frozen_string_literal: true

require "spec_helper"

describe Decidim::Meetings::Admin::UpdateMeeting do
  let(:meeting) { create(:meeting) }
  let(:organization) { meeting.feature.organization }
  let(:scope) { create :scope, organization: organization }
  let(:category) { create :category, participatory_space: meeting.feature.participatory_space }
  let(:address) { meeting.address }
  let(:invalid) { false }
  let(:latitude) { 40.1234 }
  let(:longitude) { 2.1234 }
  let(:user) { create :user, :admin }
  let(:form) do
    double(
      invalid?: invalid,
      title: { en: "title" },
      description: { en: "description" },
      location: { en: "location" },
      location_hints: { en: "location_hints" },
      start_time: 1.day.from_now,
      end_time: 1.day.from_now + 1.hour,
      scope: scope,
      category: category,
      address: address,
      latitude: latitude,
      longitude: longitude,
      current_user: user
    )
  end

  subject { described_class.new(form, meeting) }

  context "when the form is not valid" do
    let(:invalid) { true }

    it "is not valid" do
      expect { subject.call }.to broadcast(:invalid)
    end
  end

  context "when everything is ok" do
    it "updates the meeting" do
      subject.call
      expect(translated(meeting.title)).to eq "title"
    end

    it "sets the scope" do
      subject.call
      expect(meeting.scope).to eq scope
    end

    it "sets the category" do
      subject.call
      expect(meeting.category).to eq category
    end

    it "sets the latitude and longitude" do
      subject.call
      expect(meeting.latitude).to eq(latitude)
      expect(meeting.longitude).to eq(longitude)
    end

    context "events" do
      let!(:follow) { create :follow, followable: meeting, user: user }

      it "notifies the change" do
        expect(Decidim::EventsManager)
          .to receive(:publish)
          .with(
            event: "decidim.events.meetings.meeting_updated",
            event_class: Decidim::Meetings::UpdateMeetingEvent,
            resource: meeting,
            recipient_ids: [user.id]
          )

        subject.call
      end
    end
  end
end
