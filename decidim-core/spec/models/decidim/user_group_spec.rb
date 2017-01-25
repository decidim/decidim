# frozen_string_literal: true
require "spec_helper"

module Decidim
  describe UserGroup, :db do
    let(:user_group) { create(:user_group) }

    subject { user_group }

    it "is valid" do
      expect(subject).to be_valid
    end

    it "has an association of users" do
      subject.users << create(:user)
      subject.users << create(:user)
      expect(subject.users.count).to eq(2)
    end

    describe "#verify!" do
      it "mark the user group as verified" do
        subject.verify!
        expect(subject).to be_verified
      end
    end

    describe "scopes" do
      describe "#verified" do
        it "returns verified organizations" do
          create(:user_group, :verified)
          expect(UserGroup.verified.count).to eq(1)
        end
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
        let(:user_group) do
          build(
            :user_group,
            avatar: Rack::Test::UploadedFile.new(File.join(File.dirname(__FILE__), "..", "..", "..", "..", "decidim-dev", "spec", "support", "malicious.jpg"), "image/jpg")
          )
        end

        it { is_expected.to_not be_valid }
      end
    end
  end
end
