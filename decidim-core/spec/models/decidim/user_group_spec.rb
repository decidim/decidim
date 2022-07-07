# frozen_string_literal: true

require "spec_helper"

module Decidim
  describe UserGroup do
    subject { user_group }

    let(:user_group) { create(:user_group) }

    it { is_expected.to be_versioned }

    it "overwrites the log presenter" do
      expect(described_class.log_presenter_class_for(:foo))
        .to eq Decidim::AdminLog::UserGroupPresenter
    end

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

    describe "validations" do
      context "without an email" do
        let(:user_group) { build(:user_group, email: nil) }

        it { is_expected.not_to be_valid }
      end

      context "without a document number" do
        subject { another_user_group }

        let(:another_user_group) { build :user_group, organization: user_group.organization, document_number: "" }

        it { is_expected.to be_valid }
      end

      context "when the document number is taken" do
        subject { another_user_group }

        let(:another_user_group) { build :user_group, organization: user_group.organization, document_number: user_group.document_number }

        it { is_expected.not_to be_valid }
      end

      context "when the file is too big" do
        before do
          expect(subject.avatar.blob).to receive(:byte_size).at_least(:once).and_return(11.megabytes)
        end

        it { is_expected.not_to be_valid }
      end

      context "when the file is a malicious image" do
        let(:avatar_path) { Decidim::Dev.asset("malicious.jpg") }
        let(:user_group) do
          build(
            :user_group,
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

        it "doesn't allow them" do
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
  end
end
