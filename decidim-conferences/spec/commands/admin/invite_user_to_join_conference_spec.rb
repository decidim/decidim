# frozen_string_literal: true

require "spec_helper"

module Decidim::Conferences::Admin
  describe InviteUserToJoinConference do
    let(:command) { described_class.new(form, conference, invited_by) }

    let(:conference) { create :conference }
    let(:invited_by) { create :user, :admin, :confirmed, organization: conference.organization }
    let(:invited_user) { create :user, :confirmed, organization: conference.organization }
    let(:form) do
      double(
        invalid?: invalid,
        existing_user: true,
        current_organization: conference.organization,
        user: invited_user,
        registration_type:
      )
    end
    let(:invalid) { false }
    let(:registration_type) { create(:registration_type, conference:) }

    describe "call" do
      it "broadcasts ok" do
        expect { command.call }.to broadcast(:ok)
      end

      it "sends the invitation to the existing user" do
        perform_enqueued_jobs { command.call }

        email = last_email
        expect(email.to).to eq([invited_user.email])
        expect(email.subject).to eq("Invitation to join a conference")
      end

      describe "when the user is a new user" do
        let(:form) do
          double(
            invalid?: invalid,
            existing_user: false,
            current_organization: conference.organization,
            email: "jdoe@example.org",
            name: "John Doe",
            registration_type:
          )
        end

        it "broadcasts ok" do
          expect { command.call }.to broadcast(:ok)
        end

        it "sends the invitation to the user" do
          perform_enqueued_jobs { command.call }

          email = last_email
          expect(email.to).to eq(["jdoe@example.org"])
          expect(email.subject).to eq("Invitation to join a conference")
        end
      end
    end
  end
end
