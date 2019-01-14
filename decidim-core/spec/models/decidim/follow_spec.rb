# frozen_string_literal: true

require "spec_helper"

describe Decidim::Follow do
  subject { follow }

  let(:follow) { build(:follow) }

  it { is_expected.to be_valid }

  describe "uniqueness" do
    let!(:another_follow) { create :follow }
    let!(:follow) { build :follow, user: another_follow.user, followable: another_follow.followable }

    it "cannot be repeated for user/followable combo" do
      expect(subject).not_to be_valid
    end
  end

  describe "presence" do
    context "without user" do
      let(:follow) { build(:follow, user: nil) }

      it { is_expected.not_to be_valid }
    end

    context "without followable" do
      let(:follow) { build(:follow, followable: nil) }

      it { is_expected.not_to be_valid }
    end
  end

  describe "after create" do
    let(:user) { create :user }
    let(:another_user) { create :user }

    context "when following a resource" do
      it "increases the following count" do
        expect do
          create :follow, user: user
          user.reload
        end.to change(user, :following_count).by(1)
      end
    end

    context "when following a user" do
      it "increases the following count" do
        expect do
          create :follow, user: user, followable: another_user
          user.reload
        end.to change(user, :following_count).by(1)
      end
    end

    context "when being followed" do
      it "increases the followers count" do
        expect do
          create :follow, user: user, followable: another_user
          user.reload
        end.to change(another_user, :followers_count).by(1)
      end
    end
  end

  describe "after destroy" do
    let(:user) { create :user }
    let(:another_user) { create :user }

    context "when unfollowing a resource" do
      it "decreases the following count" do
        follow = create :follow, user: user
        expect do
          follow.destroy!
          user.reload
        end.to change(user, :following_count).by(-1)
      end
    end

    context "when unfollowing a user" do
      it "decreases the following count" do
        follow = create :follow, user: user, followable: another_user
        expect do
          follow.destroy!
          user.reload
        end.to change(user, :following_count).by(-1)
      end
    end

    context "when not being followed anymore" do
      it "decreases the followers count" do
        follow = create :follow, user: user, followable: another_user
        expect do
          follow.destroy!
          user.reload
        end.to change(another_user, :followers_count).by(-1)
      end
    end
  end
end
