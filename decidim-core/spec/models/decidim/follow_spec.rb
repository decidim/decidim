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
end
