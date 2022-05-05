# frozen_string_literal: true

require "spec_helper"

module Decidim::Meetings
  describe Admin::ValidateRegistrationCode do
    subject { described_class.new(form, meeting) }

    let(:meeting) { create(:meeting) }
    let(:code) { "VPAGQ2DG" }

    let(:form) do
      Admin::ValidateRegistrationCodeForm.from_params(
        code: code
      ).with_context(current_organization: meeting.organization, meeting: meeting)
    end

    context "when the form is not valid" do
      before do
        allow(form).to receive(:invalid?).and_return(true)
      end

      it "broadcasts invalid" do
        expect { subject.call }.to broadcast(:invalid)
      end
    end

    context "when everything is ok" do
      let!(:registration) { create(:registration, meeting: meeting, code: code, validated_at: nil) }

      it "broadcasts ok" do
        expect { subject.call }.to broadcast(:ok)
      end

      it "updates the registration" do
        subject.call
        registration.reload
        expect(registration.validated_at).not_to be_nil
      end
    end

    describe "events" do
      let(:user) { create :user, :confirmed, organization: meeting.organization }
      let!(:registration) { create(:registration, meeting: meeting, code: code, validated_at: nil, user: user) }

      context "when registrations are enabled and registration code is enabled" do
        before do
          meeting.component.update!(settings: { registration_code_enabled: true })
        end

        it "notifies the change" do
          expect(Decidim::EventsManager)
            .to receive(:publish)
            .with(
              event: "decidim.events.meetings.registration_code_validated",
              event_class: Decidim::Meetings::RegistrationCodeValidatedEvent,
              resource: meeting,
              affected_users: [user],
              extra: {
                registration: registration
              }
            )

          subject.call
        end
      end
    end
  end
end
