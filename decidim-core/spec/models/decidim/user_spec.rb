# frozen_string_literal: true

require "spec_helper"

module Decidim
  describe User do
    subject { user }

    let(:organization) { create(:organization) }
    let(:user) { build(:user, organization:) }

    include_examples "resourceable"

    it { is_expected.to be_valid }

    it "has traceability" do
      expect(subject).to be_a(Decidim::Traceable)
    end

    it "overwrites the log presenter" do
      expect(described_class.log_presenter_class_for(:foo))
        .to eq Decidim::AdminLog::UserPresenter
    end

    it "has an association for identities" do
      expect(subject.identities).to eq([])
    end

    describe "name" do
      context "when it has a name" do
        let(:user) { build(:user, name: "Oriol") }

        it "returns the name" do
          expect(user.name).to eq("Oriol")
        end
      end

      context "when it does not have a name" do
        let(:user) { build(:user, name: nil) }

        it "returns anonymous" do
          expect(user.name).to eq("Anonymous")
        end
      end

      context "when the user is blocked and extended_data has user_name" do
        let(:user) { build(:user, name: "Blocked user", blocked: true, extended_data: { user_name: "Test" }) }

        it "returns user name" do
          expect(user.user_name).to eq("Test")
        end
      end

      context "when the user is blocked and extended_data does not have user_name" do
        let(:user) { build(:user, name: "Blocked user", blocked: true, extended_data: {}) }

        it "returns user name" do
          expect(user.user_name).to eq("Blocked user")
        end
      end
    end

    describe "validations" do
      context "when the nickname is empty" do
        before do
          user.nickname = ""
        end

        it "is not valid" do
          expect(user).not_to be_valid
          expect(user.errors[:nickname]).to include("cannot be blank")
        end

        it "cannot be empty backed by an index" do
          expect { user.save(validate: false) }.not_to raise_error
        end

        context "when managed" do
          before do
            user.managed = true
          end

          it "is valid" do
            expect(user).to be_valid
          end

          it "can be saved" do
            expect(user.save).to be true
          end

          it "can have duplicates" do
            user.save!

            expect do
              create(:user, organization: user.organization,
                            nickname: user.nickname,
                            managed: true)
            end.not_to raise_error
          end
        end

        context "when deleted" do
          before do
            user.deleted_at = Time.current
          end

          it "is valid" do
            expect(user).to be_valid
          end

          it "can be saved" do
            expect(user.save).to be true
          end

          it "can have duplicates" do
            user.save!

            expect do
              create(:user, organization: user.organization,
                            nickname: user.nickname,
                            deleted_at: Time.current)
            end.not_to raise_error
          end
        end
      end

      context "when the nickname is not empty" do
        before do
          user.nickname = "a-nickname"
        end

        it "can be created" do
          expect(user.save).to be(true)
        end

        it "cannot have duplicates even when skipping validations" do
          user.save!

          expect do
            build(:user, organization: user.organization,
                         nickname: user.nickname).save(validate: false)
          end.to raise_error(ActiveRecord::RecordNotUnique)
        end
      end

      context "when the file is too big" do
        before do
          expect(subject.avatar.blob).to receive(:byte_size).at_least(:once).and_return(11.megabytes)
        end

        it { is_expected.not_to be_valid }
      end

      context "when the file is a malicious image" do
        let(:avatar_path) { Decidim::Dev.asset("malicious.jpg") }
        let(:user) do
          build(
            :user,
            avatar: ActiveStorage::Blob.create_and_upload!(
              io: File.open(avatar_path),
              filename: "malicious.jpeg",
              content_type: "image/jpeg"
            )
          )
        end

        it { is_expected.not_to be_valid }
      end

      context "with weird characters" do
        let(:weird_characters) do
          ["<", ">", "?", "%", "&", "^", "*", "#", "@", "(", ")", "[", "]", "=", "+", ":", ";", '"', "{", "}", " |"]
        end

        it "does not allow them" do
          weird_characters.each do |character|
            user = build(:user)
            user.name.insert(rand(0..user.name.length), character)
            user.nickname.insert(rand(0..user.nickname.length), character)

            expect(user).not_to be_valid
            expect(user.errors[:name].length).to eq(1)
            expect(user.errors[:nickname].length).to eq(1)
          end
        end
      end
    end

    describe "validation scopes" do
      context "when a user with the same email exists in another organization" do
        let(:email) { "foo@bar.com" }
        let(:user) { create(:user, email:) }

        before do
          create(:user, email:)
        end

        it { is_expected.to be_valid }
      end
    end

    describe "devise emails" do
      it "sends them asynchronously" do
        create(:user)
        expect(ActionMailer::MailDeliveryJob).to have_been_enqueued.on_queue("mailers")
      end
    end

    describe "search" do
      subject { described_class.ransack(search_params, context_params).result }

      let(:search_params) { {} }
      let(:context_params) { { auth_object: user } }

      describe "last_sign_in_at" do
        let(:cut_time) { 7.days.ago }
        let!(:last_week) { create_list(:user, 10, :confirmed, last_sign_in_at: cut_time - 3.days) }
        let!(:this_week) { create_list(:user, 5, :confirmed, last_sign_in_at: cut_time + 3.days) }

        let(:search_params) { { last_sign_in_at_gteq: cut_time } }

        it "returns the correct results" do
          expect(subject.count).to eq(5)
        end
      end
    end

    describe "#deleted?" do
      it "returns true if deleted_at is present" do
        subject.deleted_at = Time.current
        expect(subject).to be_deleted
      end
    end

    describe "#tos_accepted?" do
      subject { user.tos_accepted? }

      let(:user) { create(:user, organization:, accepted_tos_version:) }
      let(:accepted_tos_version) { organization.tos_version }

      it { is_expected.to be_truthy }

      context "when user accepted TOS before organization last update" do
        let(:organization) { build(:organization, tos_version: Time.current) }
        let(:accepted_tos_version) { 1.year.before }

        it { is_expected.to be_falsey }

        context "when organization has no TOS" do
          let(:organization) { build(:organization, tos_version: nil) }
          let(:user) { build(:user, organization:) }

          it { is_expected.to be_falsey }
        end
      end

      context "when user has not accepted the TOS" do
        let(:accepted_tos_version) { nil }

        it { is_expected.to be_falsey }

        context "when user is managed" do
          let(:user) { build(:user, :managed, organization:, accepted_tos_version:) }

          it { is_expected.to be_truthy }
        end

        context "when organization has no TOS" do
          let(:organization) { build(:organization, tos_version: nil) }

          it { is_expected.to be_falsey }
        end
      end
    end

    describe "#find_for_authentication" do
      let(:user) { create(:user, organization:) }

      let(:conditions) do
        {
          env: {
            "decidim.current_organization" => organization
          },
          email: user.email.upcase
        }
      end

      it "finds the user even with weird casing in email" do
        expect(described_class.find_for_authentication(conditions)).to eq user
      end
    end

    describe "#unread_messages_count" do
      subject { user.unread_messages_count }

      let(:originator) { create(:user, organization:) }

      before do
        conversation = Decidim::Messaging::Conversation.create!(
          participants: [originator, user]
        )

        conversation.add_message!(sender: originator, body: "Hey let's converse!", user: originator)
        conversation.add_message!(sender: originator, body: "How are you?", user: originator)
        conversation.add_message!(sender: user, body: "Good! How are you?", user:)
        conversation.mark_as_read(user)
        conversation.add_message!(sender: originator, body: "Do you like Decidim?", user: originator)
        conversation.add_message!(sender: originator, body: "Are you going to DecidimFest?", user: originator)
      end

      it "returns the correct count" do
        expect(subject).to be(2)
      end
    end

    describe "#after_confirmation" do
      let(:user) { create(:user, organization:) }

      before do
        perform_enqueued_jobs { user.confirm }
      end

      it "sends the email" do
        expect(last_email.to).to eq([user.email])
        expect(last_email.subject).to eq("Thanks for joining #{translated(organization.name)}!")
      end

      context "when the organization does not send welcome notifications" do
        let(:organization) { create(:organization, send_welcome_notification: false) }

        it "does not send the welcome email" do
          expect(last_email.subject).to eq("Confirmation instructions")
        end
      end
    end

    describe "#needs_password_update?" do
      subject { user.needs_password_update? }

      let(:user) { create(:user, :confirmed, organization:) }
      let(:password_expired_time) { Decidim.config.admin_password_expiration_days.days.ago - 1.second }

      context "with participant" do
        before { user.update!(password_updated_at: password_expired_time) }

        it { is_expected.to be(false) }
      end

      context "with admin" do
        let(:user) { create(:user, :confirmed, :admin, organization:, password_updated_at:) }
        let(:password_updated_at) { Time.current }

        context "when the password has been recently updated" do
          it { is_expected.to be(false) }
        end

        context "when the password was updated a long time ago" do
          let(:password_updated_at) { password_expired_time }

          it { is_expected.to be(true) }

          context "when strong passwords are disabled" do
            before { allow(Decidim.config).to receive(:admin_password_strong).and_return(false) }

            it { is_expected.to be(false) }
          end
        end

        context "when password_updated_at is blank" do
          let(:password_updated_at) { nil }

          it { is_expected.to be(true) }

          context "when the user has identities" do
            let!(:identity) { create(:identity, user:) }

            it { is_expected.to be(false) }
          end
        end
      end
    end

    describe "#moderator?" do
      context "when an organization has a moderator and a regular user" do
        let(:organization) { create(:organization, available_locales: [:en]) }
        let(:participatory_space) { create(:participatory_process, organization:) }
        let(:moderator) do
          create(
            :process_moderator,
            :confirmed,
            organization:,
            participatory_process: participatory_space
          )
        end

        it "returns false when user is not a moderator" do
          expect(subject.moderator?).to be false
        end

        it "returns true when user is a moderator" do
          expect(moderator.moderator?).to be true
        end
      end
    end
  end
end
