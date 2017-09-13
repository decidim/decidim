# frozen_string_literal: true

require "spec_helper"

describe Decidim::Meetings::Admin::CreateMeeting do
  let(:organization) { create :organization, available_locales: [:en] }
  let(:participatory_process) { create :participatory_process, organization: organization }
  let(:current_feature) { create :feature, participatory_space: participatory_process, manifest_name: "meetings" }
  let(:scope) { create :scope, organization: organization }
  let(:category) { create :category, participatory_space: participatory_process }
  let(:address) { "address" }
  let(:invalid) { false }
  let(:latitude) { 40.1234 }
  let(:longitude) { 2.1234 }
  let(:start_time) { 1.day.from_now }
  let(:form) do
    double(
      invalid?: invalid,
      title: { en: "title" },
      description: { en: "description" },
      location: { en: "location" },
      location_hints: { en: "location_hints" },
      start_time: start_time,
      end_time: 1.day.from_now + 1.hour,
      address: address,
      latitude: latitude,
      longitude: longitude,
      scope: scope,
      category: category,
      current_feature: current_feature
    )
  end

  subject { described_class.new(form) }

  context "when the form is not valid" do
    let(:invalid) { true }

    it "is not valid" do
      expect { subject.call }.to broadcast(:invalid)
    end
  end

  context "when everything is ok" do
    let(:meeting) { Decidim::Meetings::Meeting.last }

    it "creates the meeting" do
      expect { subject.call }.to change { Decidim::Meetings::Meeting.count }.by(1)
    end

    it "sets the scope" do
      subject.call
      expect(meeting.scope).to eq scope
    end

    it "sets the category" do
      subject.call
      expect(meeting.category).to eq category
    end

    it "sets the feature" do
      subject.call
      expect(meeting.feature).to eq current_feature
    end

    it "sets the longitude and latitude" do
      subject.call
      last_meeting = Decidim::Meetings::Meeting.last
      expect(last_meeting.latitude).to eq(latitude)
      expect(last_meeting.longitude).to eq(longitude)
    end

    it "schedules a upcoming meeting notification job 48h before start time" do
      expect_any_instance_of(Decidim::Meetings::Meeting)
        .to receive(:id).at_least(:once).and_return 1

      expect(Decidim::Meetings::UpcomingMeetingNotificationJob)
        .to receive(:generate_checksum).and_return "1234"

      expect(Decidim::Meetings::UpcomingMeetingNotificationJob)
        .to receive_message_chain(:set, :perform_later)
        .with(set: start_time - 2.days).with(1, "1234")

      subject.call
    end
  end
end
