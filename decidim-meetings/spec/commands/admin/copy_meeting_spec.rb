# frozen_string_literal: true

require "spec_helper"

module Decidim::Meetings
  describe Admin::CopyMeeting do
    subject { described_class.new(form, meeting) }

    let(:meeting) { create :meeting }

    let(:current_user) { create :user, :admin, :confirmed, organization: meeting.organization }
    let(:address) { "address" }
    let(:invalid) { false }
    let(:latitude) { 40.1234 }
    let(:longitude) { 2.1234 }
    let(:start_time) { 1.day.from_now }
    let(:is_private) { false }
    let(:is_transparent) { true }

    let(:form) do
      double(
        invalid?: invalid,
        title: { en: "title" },
        description: { en: "description" },
        location: { en: "location" },
        location_hints: { en: "location hints" },
        start_time: start_time,
        end_time: 1.day.from_now + 1.hour,
        address: address,
        latitude: latitude,
        longitude: longitude,
        scope: meeting.scope,
        category: meeting.category,
        current_user: current_user,
        organizer: meeting.organizer,
        is_private: meeting.is_private,
        is_transparent: meeting.is_transparent,
        current_component: meeting.component
      )
    end

    context "when the form is not valid" do
      let(:invalid) { true }

      it "broadcasts invalid" do
        expect { subject.call }.to broadcast(:invalid)
      end
    end

    context "when everything is ok" do
      it "duplicates a meeting" do
        expect { subject.call }.to change(Meeting, :count).by(2)

        old_meeting = Meeting.first
        new_meeting = Meeting.last

        expect(new_meeting.title["en"]).to eq("title")
        expect(new_meeting.description["en"]).to eq("description")
        expect(new_meeting.scope).to eq(old_meeting.scope)
        expect(new_meeting.category).to eq(old_meeting.category)
        expect(new_meeting.component).to eq(old_meeting.component)
      end

      it "broadcasts ok" do
        expect { subject.call }.to broadcast(:ok)
      end
    end
  end
end
