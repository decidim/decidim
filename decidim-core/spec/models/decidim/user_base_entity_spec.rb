# frozen_string_literal: true

require "spec_helper"

module Decidim
  describe UserBaseEntity do
    subject { user }

    let(:organization) { create(:organization) }
    let(:user) { build(:user, organization:) }

    describe "public followings" do
      let(:user_followed) { create(:user, organization: user.organization) }
      let(:public_resource) { create(:dummy_resource, :published) }
      let(:user_blocked) { create(:user, organization: user.organization, blocked: true) }

      before do
        user.save!
        create(:follow, user:, followable: user_followed)
        create(:follow, user:, followable: public_resource)
        create(:follow, user:, followable: user_blocked)
      end

      it "return all the things followed unless the blocked users" do
        expect(subject.public_followings).to contain_exactly(public_resource, user_followed)
      end
    end

    describe "#validates :name" do
      context "when name is John Doe" do
        let(:user) { build(:user, organization:, name: "John Doe") }

        it "is valid" do
          expect(user).to be_valid
        end
      end

      context "when name contains newlines" do
        let(:user) { build(:user, organization:, name: "John\n<script>alert('name')</script>") }

        it "is invalid" do
          expect(user).not_to be_valid
          expect(user.errors[:name]).to be_present
        end
      end

      context "when name contains carriage return" do
        let(:user) { build(:user, organization:, name: "John\r<script>alert('name')</script>") }

        it "is invalid" do
          expect(user).not_to be_valid
          expect(user.errors[:name]).to be_present
        end
      end
    end

    describe "#validates :nickname" do
      context "when nickname is john_doe" do
        let(:user) { build(:user, organization:, nickname: "john_doe") }

        it "is valid" do
          expect(user).to be_valid
        end
      end

      context "when nickname contains newlines" do
        let(:user) { build(:user, organization:, nickname: "john\n<script>alert('nickname')</script>") }

        it "is invalid" do
          expect(user).not_to be_valid
          expect(user.errors[:nickname]).to be_present
        end
      end

      context "when nickname contains carriage return" do
        let(:user) { build(:user, organization:, nickname: "john\r<script>alert('nickname')</script>") }

        it "is invalid" do
          expect(user).not_to be_valid
          expect(user.errors[:nickname]).to be_present
        end
      end
    end
  end
end
