# frozen_string_literal: true

require "spec_helper"

module Decidim::Conferences
  describe Admin::UpdateRegistrationType do
    subject { described_class.new(form, registration_type) }

    let!(:conference) { create(:conference) }
    let(:registration_type) { create :registration_type, conference: conference }
    let!(:current_user) { create :user, :confirmed, organization: conference.organization }
    let!(:meeting_component) do
      create(:component, manifest_name: :meetings, participatory_space: conference)
    end
    let!(:meetings) do
      create_list(
        :meeting,
        3,
        component: meeting_component
      )
    end
    let(:form) do
      double(
        Admin::RegistrationTypeForm,
        invalid?: invalid,
        current_user: current_user,
        title: { en: "New title" },
        attributes: {
          "title" => { en: "New title" },
          "weight" => 2,
          "description" => { en: "New description" }
        }
      )
    end

    let(:invalid) { false }

    context "when the form is not valid" do
      let(:invalid) { true }

      it "is not valid" do
        expect { subject.call }.to broadcast(:invalid)
      end
    end

    context "when everything is ok" do
      it "updates the registration type title" do
        expect do
          subject.call
        end.to change { registration_type.reload && registration_type.title }.from(registration_type.title).to("en" => "New title", "machine_translations" => kind_of(Hash))
      end

      it "updates the registration type description" do
        expect do
          subject.call
        end.to change { registration_type.reload && registration_type.description }.from(registration_type.description).to("en" => "New description", "machine_translations" => kind_of(Hash))
      end

      it "broadcasts ok" do
        expect { subject.call }.to broadcast(:ok)
      end

      it "traces the action", versioning: true do
        expect(Decidim.traceability)
          .to receive(:update!)
          .with(registration_type, current_user, kind_of(Hash), hash_including(resource: hash_including(:title)))
          .and_call_original

        expect { subject.call }.to change(Decidim::ActionLog, :count)
        action_log = Decidim::ActionLog.last
        expect(action_log.version).to be_present
      end

      it "links meetings" do
        subject.call

        conference_meetings = []
        meetings.each do |meeting|
          conference_meetings << meeting.becomes(Decidim::ConferenceMeeting)
        end

        registration_type.conference_meetings = conference_meetings
        expect(registration_type.conference_meetings).to match_array(conference_meetings)
      end
    end
  end
end
