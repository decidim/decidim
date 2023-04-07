# frozen_string_literal: true

require "spec_helper"

module Decidim::Assemblies
  describe Admin::CreateAssemblyAdmin do
    subject { described_class.new(form, my_assembly) }

    let(:my_assembly) { create :assembly }
    let!(:email) { "my_email@example.org" }
    let!(:role) { "admin" }
    let!(:name) { "Weird Guy" }
    let!(:user) { create :user, email: "my_email@example.org", organization: my_assembly.organization }
    let!(:current_user) { create :user, email: "some_email@example.org", organization: my_assembly.organization }
    let(:form) do
      double(
        invalid?: invalid,
        email:,
        role:,
        name:,
        current_user:,
        current_participatory_space: my_assembly
      )
    end
    let(:invalid) { false }
    let(:user_notification) do
      {
        event: "decidim.events.assembly.role_assigned",
        event_class: Decidim::RoleAssignedToAssemblyEvent,
        resource: my_assembly,
        affected_users: [user],
        extra: { role: kind_of(String) }
      }
    end

    context "when the form is not valid" do
      let(:invalid) { true }

      it "is not valid" do
        expect { subject.call }.to broadcast(:invalid)
      end
    end

    context "when everything is ok" do
      let(:log_info) do
        hash_including(
          resource: hash_including(
            title: kind_of(String)
          )
        )
      end
      let(:role_params) do
        {
          role: role.to_sym,
          user:,
          assembly: my_assembly
        }
      end

      it "creates the user role" do
        subject.call
        roles = Decidim::AssemblyUserRole.where(user:)

        expect(roles.count).to eq 1
        expect(roles.first.role).to eq "admin"
      end

      it "sends a notification to the user with the role assigned" do
        expect(Decidim::EventsManager).to receive(:publish).with(user_notification)

        subject.call
      end

      it "does not add admin privileges to the user" do
        subject.call
        user.reload

        expect(user).not_to be_admin
      end

      it "makes the new admin follow the process" do
        subject.call
        user.reload

        expect(user.follows?(my_assembly)).to be true
      end

      it "traces the action", versioning: true do
        expect(Decidim.traceability)
          .to receive(:create!)
          .with(Decidim::AssemblyUserRole, current_user, role_params, log_info)
          .and_call_original

        expect { subject.call }.to change(Decidim::ActionLog, :count)

        action_log = Decidim::ActionLog.last
        expect(action_log.version).to be_present
        expect(action_log.version.event).to eq "create"
      end

      it "does not invite the user again" do
        subject.call
        user.reload

        expect(user.invited_to_sign_up?).not_to be true
      end

      context "when there is no user with the given email" do
        let(:email) { "does_not_exist@example.com" }

        it "creates a new user with said email" do
          subject.call
          expect(Decidim::User.last.email).to eq(email)
        end

        it "creates a new user with no application admin privileges" do
          subject.call
          expect(Decidim::User.last).not_to be_admin
        end
      end

      context "when a user and a role already exist" do
        before do
          subject.call
        end

        it "does not get created twice" do
          expect { subject.call }.to broadcast(:ok)

          roles = Decidim::AssemblyUserRole.where(user:)

          expect(roles.count).to eq 1
          expect(roles.first.role).to eq "admin"
        end
      end

      context "when the user has not accepted the invitation" do
        before do
          user.invite!
        end

        it "gets the invitation resent" do
          expect { subject.call }.to have_enqueued_job(ActionMailer::MailDeliveryJob)
        end
      end
    end
  end
end
