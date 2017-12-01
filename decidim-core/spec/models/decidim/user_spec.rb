# frozen_string_literal: true

require "spec_helper"

module Decidim
  describe User do
    subject { user }

    let(:organization) { build(:organization) }
    let(:user) { build(:user, organization: organization) }

    it { is_expected.to be_valid }

    it "has an association for identities" do
      expect(subject.identities).to eq([])
    end

    it "has an association for user groups" do
      user_group = create(:user_group)
      create(:user_group_membership, user: subject, user_group: user_group)
      expect(subject.user_groups).to eq([user_group])
    end

    describe "name" do
      context "when it has a name" do
        let(:user) { build(:user, name: "Oriol") }

        it "returns the name" do
          expect(user.name).to eq("Oriol")
        end
      end

      context "when it doesn't have a name" do
        let(:user) { build(:user, name: nil) }

        it "returns anonymous" do
          expect(user.name).to eq("Anonymous")
        end
      end
    end

    describe "validations", processing_uploads_for: Decidim::AvatarUploader do
      context "when the email is a disposable account" do
        before do
          user.email = "user@mailbox92.biz"
        end

        it "is not valid" do
          expect(user).not_to be_valid
          expect(user.errors[:email].length).to eq(1)
        end
      end

      context "when the file is too big" do
        before do
          expect(subject.avatar).to receive(:size).and_return(11.megabytes)
        end

        it { is_expected.not_to be_valid }
      end

      context "when the file is a malicious image" do
        let(:avatar_path) { Decidim::Dev.asset("malicious.jpg") }
        let(:user) do
          build(
            :user,
            avatar: Rack::Test::UploadedFile.new(avatar_path, "image/jpg")
          )
        end

        it { is_expected.not_to be_valid }
      end
    end

    describe "validation scopes" do
      context "when a user with the same email exists in another organization" do
        let(:email) { "foo@bar.com" }
        let(:user) { create(:user, email: email) }

        before do
          create(:user, email: email)
        end

        it { is_expected.to be_valid }
      end
    end

    describe "devise emails" do
      it "sends them asynchronously" do
        create(:user)
        expect(ActionMailer::DeliveryJob).to have_been_enqueued.on_queue("mailers")
      end
    end

    describe "#deleted?" do
      it "returns true if deleted_at is present" do
        subject.deleted_at = Time.current
        expect(subject).to be_deleted
      end
    end
  end
end
