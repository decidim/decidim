# frozen_string_literal: true

require "spec_helper"

module Decidim::Admin
  describe CreateParticipatorySpacePrivateUser do
    subject { described_class.new(form, current_user, privatable_to, via_csv: via_csv) }

    let(:via_csv) { false }
    let(:privatable_to) { create :participatory_process }
    let!(:email) { "my_email@example.org" }
    let!(:name) { "Weird Guy" }
    let!(:user) { create :user, email: "my_email@example.org", organization: privatable_to.organization }
    let!(:current_user) { create :user, email: "some_email@example.org", organization: privatable_to.organization }
    let(:form) do
      double(
        invalid?: invalid,
        delete_current_private_participants?: delete,
        email: email,
        name: name
      )
    end
    let(:delete) {false }
    let(:invalid) { false }

    context "when the form is not valid" do
      let(:invalid) { true }

      it "is not valid" do
        expect { subject.call }.to broadcast(:invalid)
      end
    end

    context "when everything is ok" do
      it "creates the private user" do
        subject.call

        participatory_space_private_users = Decidim::ParticipatorySpacePrivateUser.where(user: user)

        expect(participatory_space_private_users.count).to eq 1
      end

      it "creates a new user with no application admin privileges" do
        subject.call
        expect(Decidim::User.last).not_to be_admin
      end

      it "traces the action", versioning: true do
        expect(Decidim.traceability)
          .to receive(:perform_action!)
          .with(
            "create",
            Decidim::ParticipatorySpacePrivateUser,
            current_user,
            resource: { title: user.name }
          )
          .and_call_original

        expect { subject.call }.to change(Decidim::ActionLog, :count)
        action_log = Decidim::ActionLog.last
        expect(action_log.version).to be_nil
      end

      context "when the creation is performed via csv" do
        let(:via_csv) { true }

        it "uses another action to track the changes" do
          expect(Decidim.traceability)
            .to receive(:perform_action!)
            .with(
              "create_via_csv",
              Decidim::ParticipatorySpacePrivateUser,
              current_user,
              resource: { title: user.name }
            )

          subject.call
        end

        context "when the current users are not to be deleted" do
          let(:user1) { create(:user,organization: privatable_to.organization)}

          before do
            Decidim::ParticipatorySpacePrivateUser.create!(decidim_user_id: user1.id,privatable_to_id: privatable_to.id, privatable_to_type: privatable_to.class.to_s)
          end

          it "doesn't suppress the existing users" do
            expected_number=Decidim::ParticipatorySpacePrivateUser.where(privatable_to_id: privatable_to.id, privatable_to_type: privatable_to.class.to_s).count

            subject.call
            byebug
            expect(Decidim::ParticipatorySpacePrivateUser.where(privatable_to_id: privatable_to.id, privatable_to_type: privatable_to.class.to_s).count).to equal(1+expected_number)
          end
        end

        context "when the current users are to be deleted" do
          let(:delete) { true }

          it "suppress the existing users" do
            subject.call

            expect(Decidim::ParticipatorySpacePrivateUser.where(privatable_to_id: privatable_to.id, privatable_to_type: privatable_to.class.to_s).count).to equal(1)
          end
        end
      end

      it "don't invite the user again" do
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

      context "when a private user exist" do
        before do
          subject.call
        end

        it "doesn't get created twice" do
          expect { subject.call }.to broadcast(:ok)

          participatory_space_private_users = Decidim::ParticipatorySpacePrivateUser.where(user: user)

          expect(participatory_space_private_users.count).to eq 1
        end
      end

      context "when the user hasn't accepted the invitation" do
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
