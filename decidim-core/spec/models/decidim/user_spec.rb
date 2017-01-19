# frozen_string_literal: true
require "spec_helper"

module Decidim
  describe User, :db do
    let(:organization) { build(:organization) }
    let(:user) { build(:user, organization: organization) }
    subject { user}

    it { is_expected.to be_valid }

    it "has an association for identities" do
      expect(subject.identities).to eq([])
    end

    context "with roles" do
      let(:user) { build(:user, :admin) }

      it { is_expected.to be_valid }

      context "with an invalid role" do
        let(:user) { build(:user, roles: ["foo"]) }

        it { is_expected.to_not be_valid }
      end
    end

    describe "validations" do
      before do
        Decidim::AvatarUploader.enable_processing = true
      end

      context "when the file is too big" do
        before do
          expect(subject.avatar).to receive(:size).and_return(11.megabytes)
        end

        it { is_expected.to_not be_valid }
      end

      context "when the file is a malicious image" do
        let(:user) do
          build(
            :user,
            avatar: Rack::Test::UploadedFile.new(File.join(File.dirname(__FILE__), "..", "..", "..", "..", "decidim-dev", "spec", "support", "malicious.jpg"), "image/jpg")
          )
        end

        it { is_expected.to_not be_valid }
      end
    end

    describe "validation scopes" do
      context "when a user with the same email exists in another organization" do
        let(:email) { "foo@bar.com" }
        let(:user) { build(:user, email: email) }

        before do
          create(:user, email: email)
        end

        it { is_expected.to be_valid }
      end
    end

    context "devise emails" do
      it "sends them asynchronously" do
        create(:user)
        expect(ActionMailer::DeliveryJob).to have_been_enqueued.on_queue("mailers")
      end
    end
  end
end
