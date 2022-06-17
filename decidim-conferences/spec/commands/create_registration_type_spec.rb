# frozen_string_literal: true

require "spec_helper"

module Decidim::Conferences
  describe Admin::CreateRegistrationType do
    subject { described_class.new(form, current_user, conference) }

    let(:conference) { create(:conference) }
    let(:user) { nil }
    let!(:current_user) { create :user, :confirmed, organization: conference.organization }
    let(:meeting_component) do
      create(:component, manifest_name: :meetings, participatory_space: conference)
    end

    let(:meetings) do
      create_list(
        :meeting,
        3,
        component: meeting_component
      )
    end
    let(:meeting_ids) { meetings.map(&:id) }

    let(:form) do
      double(
        Admin::RegistrationTypeForm,
        invalid?: invalid,
        current_user:,
        title: { en: "title" },
        attributes: {
          "title" => { en: "title" },
          "weight" => 1,
          "price" => 300,
          "description" => { en: "registration type description" }
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
      let(:registration_type) { Decidim::Conferences::RegistrationType.last }

      it "creates a registration type" do
        expect { subject.call }.to change { Decidim::Conferences::RegistrationType.count }.by(1)
      end

      it "broadcasts ok" do
        expect { subject.call }.to broadcast(:ok)
      end

      it "sets the registration type" do
        subject.call
        expect(registration_type.conference).to eq conference
      end

      it "traces the action", versioning: true do
        expect(Decidim.traceability)
          .to receive(:perform_action!)
          .with(:create, Decidim::Conferences::RegistrationType, current_user, { participatory_space: { title: conference.title }, resource: { title: form.title } })
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
