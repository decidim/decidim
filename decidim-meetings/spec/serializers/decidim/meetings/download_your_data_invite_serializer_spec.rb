# frozen_string_literal: true

require "spec_helper"

module Decidim::Meetings
  describe DownloadYourDataInviteSerializer do
    let(:resource) { build_stubbed(:invite) }

    subject { described_class.new(resource) }

    describe "#serialize" do
      it "includes the invite data" do
        serialized = subject.serialize

        expect(serialized).to be_a(Hash)

        expect(subject.serialize).to include(id: resource.id)
        expect(subject.serialize).to include(sent_at: resource.sent_at)
        expect(subject.serialize).to include(accepted_at: resource.accepted_at)
        expect(subject.serialize).to include(rejected_at: resource.rejected_at)
      end

      it "includes the user" do
        serialized_user = subject.serialize[:user]

        expect(serialized_user).to be_a(Hash)

        expect(serialized_user).to include(name: resource.user.name)
        expect(serialized_user).to include(email: resource.user.email)
      end

      it "includes the meeting" do
        serialized_meeting = subject.serialize[:meeting]

        expect(serialized_meeting).to be_a(Hash)

        expect(serialized_meeting).to include(title: resource.meeting.title)
        expect(serialized_meeting).to include(description: resource.meeting.description)
        expect(serialized_meeting).to include(start_time: resource.meeting.start_time)
        expect(serialized_meeting).to include(end_time: resource.meeting.end_time)
        expect(serialized_meeting).to include(address: resource.meeting.address)
        expect(serialized_meeting).to include(location: resource.meeting.location)
        expect(serialized_meeting).to include(location_hints: resource.meeting.location_hints)
        expect(serialized_meeting).to include(reference: resource.meeting.reference)
        expect(serialized_meeting).to include(attendees_count: resource.meeting.attendees_count)
        expect(serialized_meeting).to include(attending_organizations: resource.meeting.attending_organizations)
        expect(serialized_meeting).to include(closed_at: resource.meeting.closed_at)
        expect(serialized_meeting).to include(closing_report: resource.meeting.closing_report)
        expect(serialized_meeting).to include(published_at: resource.meeting.published_at)
      end
    end
  end
end
