# frozen_string_literal: true

require "spec_helper"

module Decidim
  describe UserGroup do
    subject { user_group }

    let(:user_group) { create(:user_group) }

    it "is valid" do
      expect(subject).to be_valid
    end

    it "has an association of users" do
      subject.users << create(:user)
      subject.users << create(:user)
      expect(subject.users.count).to eq(2)
    end

    describe "scopes" do
      describe "#verified" do
        it "returns verified organizations" do
          create(:user_group, :verified)
          expect(UserGroup.verified.count).to eq(1)
        end
      end

      describe "#rejected" do
        it "returns rejected organizations" do
          create(:user_group, :rejected)
          expect(UserGroup.rejected.count).to eq(1)
        end
      end
    end

    describe "validations", processing_uploads_for: Decidim::AvatarUploader do
      context "when the file is too big" do
        before do
          expect(subject.avatar).to receive(:size).and_return(11.megabytes)
        end

        it { is_expected.not_to be_valid }
      end

      context "when the file is a malicious image" do
        let(:avatar_path) { Decidim::Dev.asset("malicious.jpg") }
        let(:user_group) do
          build(
            :user_group,
            avatar: Rack::Test::UploadedFile.new(avatar_path, "image/jpg")
          )
        end

        it { is_expected.not_to be_valid }
      end
    end
  end
end
