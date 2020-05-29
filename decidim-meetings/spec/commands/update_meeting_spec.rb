# frozen_string_literal: true

require "spec_helper"

module Decidim::Meetings
  describe UpdateMeeting do
    subject { described_class.new(form, current_user, meeting) }

    let(:meeting) { create :meeting }
    let(:organization) { meeting.component.organization }
    let(:current_user) { create :user, :confirmed, organization: organization }
    let(:participatory_process) { meeting.component.participatory_space }
    let(:current_component) { meeting.component }
    let(:scope) { create :scope, organization: organization }
    let(:category) { create :category, participatory_space: participatory_process }
    let(:address) { "address" }
    let(:invalid) { false }
    let(:latitude) { 40.1234 }
    let(:longitude) { 2.1234 }
    let(:start_time) { 1.day.from_now }
    let(:organizer) { create :user, organization: organization }
    let(:private_meeting) { false }
    let(:transparent) { true }
    let(:transparent_type) { "transparent" }
    let(:form) do
      double(
        invalid?: invalid,
        title: "The meeting title",
        description: "The meeting description text",
        location: "The meeting location text",
        location_hints: "The meeting location hint text",
        start_time: 1.day.from_now,
        end_time: 1.day.from_now + 1.hour,
        scope: scope,
        category: category,
        address: address,
        latitude: latitude,
        longitude: longitude,
        organizer: organizer,
        private_meeting: private_meeting,
        transparent: transparent,
        current_user: current_user,
        current_organization: organization
      )
    end

    context "when the form is not valid" do
      let(:invalid) { true }

      it "is not valid" do
        expect { subject.call }.to broadcast(:invalid)
      end
    end

    context "when everything is ok" do
      it "updates the meeting" do
        subject.call

        expect(meeting.title).to eq "The meeting title"
        expect(meeting.description).to eq "The meeting description text"
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

      context "when the organizer is a user_group" do
        let(:organizer) { create :user_group, users: [user], organization: organization }

        xit "sets the user_group as the organizer" do
          subject.call
          expect(meeting.organizer).to eq organizer
        end
      end

      context "when the organizer is a user" do
        xit "sets the user as the organizer" do
          subject.call
          expect(meeting.organizer).to eq organizer
        end
      end

      it "traces the action", versioning: true do
        expect(Decidim.traceability)
          .to receive(:update!)
          .with(meeting, current_user, kind_of(Hash))
          .and_call_original

        expect { subject.call }.to change(Decidim::ActionLog, :count)
        action_log = Decidim::ActionLog.last
        expect(action_log.version).to be_present
        expect(action_log.version.event).to eq "update"
      end

      describe "events" do
        xit "notifies when time changes"
      end
    end
  end
end
