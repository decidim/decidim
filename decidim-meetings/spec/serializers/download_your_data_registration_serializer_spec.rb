# frozen_string_literal: true

require "spec_helper"

module Decidim::Meetings
  describe DownloadYourDataRegistrationSerializer do
    let(:resource) { create(:registration) }

    subject { described_class.new(resource) }

    describe "#serialize" do
      it "includes the id" do
        expect(subject.serialize).to include(id: resource.id)
      end

      it "includes the registration code" do
        expect(subject.serialize).to include(code: resource.code)
      end

      it "includes the user" do
        expect(subject.serialize[:user]).to(
          include(name: resource.user.name)
        )
        expect(subject.serialize[:user]).to(
          include(email: resource.user.email)
        )
      end

      it "includes the meeting" do
        expect(subject.serialize[:meeting]).to(
          include(title: resource.meeting.title)
        )

        expect(subject.serialize[:meeting]).to(
          include(description: resource.meeting.description)
        )

        expect(subject.serialize[:meeting]).to(
          include(start_time: resource.meeting.start_time)
        )

        expect(subject.serialize[:meeting]).to(
          include(end_time: resource.meeting.end_time)
        )

        expect(subject.serialize[:meeting]).to(
          include(address: resource.meeting.address)
        )

        expect(subject.serialize[:meeting]).to(
          include(location: resource.meeting.location)
        )

        expect(subject.serialize[:meeting]).to(
          include(location_hints: resource.meeting.location_hints)
        )

        expect(subject.serialize[:meeting]).to(
          include(reference: resource.meeting.reference)
        )

        expect(subject.serialize[:meeting]).to(
          include(attendees_count: resource.meeting.attendees_count)
        )

        expect(subject.serialize[:meeting]).to(
          include(attending_organizations: resource.meeting.attending_organizations)
        )

        expect(subject.serialize[:meeting]).to(
          include(closed_at: resource.meeting.closed_at)
        )

        expect(subject.serialize[:meeting]).to(
          include(closing_report: resource.meeting.closing_report)
        )

        expect(subject.serialize[:meeting]).to(
          include(published_at: resource.meeting.published_at)
        )
      end
    end
  end
end
